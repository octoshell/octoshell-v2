require 'main_spec_helper'
require 'timeout'

module Core
  RSpec.describe 'Access synchronization concurrency' do
    let!(:access) { create(:core_access) }
    let(:lock_key) { "core:access_sync:#{access.id}" }

    before { Sidekiq::Testing.fake! }
    after { Sidekiq::Testing.inline! }
    after { RedisMutex.redis.del(lock_key) }

    it 'does not synchronize two resource controls of the same access simultaneously' do
      first_control, second_control = access.resource_controls.order(:id).limit(2).to_a
      expect(first_control.access_id).to eq(second_control.access_id)

      access_record = access
      first_control_id = first_control.id
      second_control_id = second_control.id
      lock_key_value = lock_key

      entered = Queue.new
      second_started = Queue.new
      release_first = Queue.new
      errors = Queue.new
      state_lock = Mutex.new
      state = { active: 0, max_active: 0, entries: [] }

      synchronizer = Object.new
      synchronizer.define_singleton_method(:run_resource_controls!) do
        index = state_lock.synchronize do
          state[:active] += 1
          state[:max_active] = [state[:max_active], state[:active]].max
          state[:entries] << Thread.current[:control_id]
          state[:entries].size
        end

        entered << Thread.current[:control_id]
        release_first.pop if index == 1
        state_lock.synchronize { state[:active] -= 1 }
      end

      original_synchronizer_new = Synchronizer.method(:new)
      original_access_find = Core::Access.method(:find)
      Synchronizer.define_singleton_method(:new) { |_access| synchronizer }
      Core::Access.define_singleton_method(:find) { |_id| access_record }
      access_record.define_singleton_method(:reload) { self }
      RedisMutex.redis.del(lock_key_value)

      first_thread = Thread.new do
        Thread.current[:control_id] = first_control_id
        AccessSynchronizer.new.perform(access_record.id, :resource_controls)
      rescue StandardError => e
        errors << e
      end

      begin
        expect(Timeout.timeout(5) { entered.pop }).to eq(first_control_id)

        second_thread = Thread.new do
          Thread.current[:control_id] = second_control_id
          second_started << true
          AccessSynchronizer.new.perform(access_record.id, :resource_controls)
        rescue StandardError => e
          errors << e
        end
        Timeout.timeout(5) { second_started.pop }

        second_entry = begin
          Timeout.timeout(1) { entered.pop }
        rescue Timeout::Error
          nil
        end

        expect(second_entry).to be_nil
        expect(state_lock.synchronize { state[:max_active] }).to eq(1)
        expect(state_lock.synchronize { state[:entries] }).to eq([first_control_id])

        release_first << true
        expect(Timeout.timeout(5) { entered.pop }).to eq(second_control_id)
        first_thread.join(5)
        second_thread.join(5)

        expect(errors).to be_empty
        expect(state_lock.synchronize { state[:max_active] }).to eq(1)
        expect(state_lock.synchronize { state[:entries] }).to eq([first_control_id, second_control_id])
      ensure
        release_first << true
        [first_thread, second_thread].compact.each do |thread|
          thread.join(1)
          thread.kill if thread.alive?
        end
        Synchronizer.define_singleton_method(:new, original_synchronizer_new)
        Core::Access.define_singleton_method(:find, original_access_find)
        RedisMutex.redis.del(lock_key_value)
      end
    end
  end
end
