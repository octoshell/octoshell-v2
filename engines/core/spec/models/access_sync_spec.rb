require 'main_spec_helper'

module Core
  RSpec.describe Access do
    let!(:access) { create(:core_access) }
    let(:lock_key) { "core:access_sync:#{access.id}" }

    after { RedisMutex.redis.del(lock_key) }

    describe '#synchronize_resource_controls!' do
      it 'runs control synchronization under the access lock and releases it afterwards' do
        synchronizer = instance_double(Synchronizer, run_resource_controls!: true)
        allow(Synchronizer).to receive(:new) do
          expect(RedisMutex.new(lock_key).locked?).to be true
          synchronizer
        end

        access.synchronize_resource_controls!

        expect(synchronizer).to have_received(:run_resource_controls!)
        expect(RedisMutex.new(lock_key).locked?).to be false
      end
    end

    describe '#synchronize!' do
      it 'runs full synchronization under the same access lock and releases it afterwards' do
        synchronizer = instance_double(Synchronizer, run!: true)
        allow(Synchronizer).to receive(:new) do
          expect(RedisMutex.new(lock_key).locked?).to be true
          synchronizer
        end

        access.synchronize!

        expect(synchronizer).to have_received(:run!)
        expect(RedisMutex.new(lock_key).locked?).to be false
      end
    end

    describe '#enqueue_resource_controls_synchronize' do
      it 'enqueues a resource controls sync for the access' do
        expect(AccessSynchronizer).to receive(:perform_async)
          .with(access.id, :resource_controls)

        access.enqueue_resource_controls_synchronize
      end
    end
  end
end
