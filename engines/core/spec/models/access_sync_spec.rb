require 'main_spec_helper'

module Core
  RSpec.describe Access do
    let!(:access) { create(:core_access) }
    let(:lock_key) { "core:access_sync:#{access.id}" }

    after { RedisMutex.redis.del(lock_key) }

    it 'does not deny unlisted partitions by default' do
      expect(described_class.new.deny_unlisted_partitions).to be false
    end

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

    describe '#listed_partition_ids and #unlisted_partitions' do
      it 'returns all cluster partitions as unlisted when there are no controls' do
        empty_access = described_class.create!(project: create(:project), cluster: create(:cluster))

        expect(empty_access.listed_partition_ids).to be_empty
        expect(empty_access.unlisted_partitions.pluck(:id))
          .to match_array(empty_access.cluster.partitions.pluck(:id))
      end

      it 'excludes partitions listed in any resource control' do
        expect(access.listed_partition_ids)
          .to match_array(access.cluster.partitions.pluck(:id))
        expect(access.unlisted_partitions).to be_empty
      end
    end

    describe '#sync_partition_access' do
      it 'executes add_assoc with the given limits' do
        partition = access.cluster.partitions.first
        connection = double('ssh connection')

        allow(access.cluster).to receive(:log)
        expect(access.cluster).to receive(:execute)
          .with(a_string_including("-p #{partition.name}", '-s 6', '-j 3'), connection)
          .and_return([0, '', ''])

        access.sync_partition_access(partition, 6, 3, connection)
      end
    end
  end
end
