require 'main_spec_helper'

RSpec.describe Synchronizer do
  let(:access) { create(:core_access) }
  let(:connection) { double('ssh connection', close: nil) }

  describe '#run_resource_controls!' do
    it 'synchronizes all access controls sequentially over one connection' do
      allow(Net::SSH).to receive(:start).and_return(connection)
      synced_control_ids = []

      allow_any_instance_of(Core::ResourceControl).to receive(:synchronize) do |control, ssh|
        expect(ssh).to eq(connection)
        synced_control_ids << control.id
      end
      expect(connection).to receive(:close)

      described_class.new(access).run_resource_controls!

      expect(synced_control_ids).to eq(access.resource_controls.order(:id).pluck(:id))
    end

    it 'raises without synchronizing controls when the connection fails' do
      allow(Net::SSH).to receive(:start).and_raise(StandardError, 'connection failed')
      expect_any_instance_of(Core::ResourceControl).not_to receive(:synchronize)

      expect { described_class.new(access).run_resource_controls! }
        .to raise_error(RuntimeError, 'No connection to cluster')
    end
  end

  describe '#run!' do
    it 'closes the connection when synchronization fails' do
      allow(Net::SSH).to receive(:start).and_return(connection)
      allow_any_instance_of(described_class).to receive(:sync_project).and_raise('sync failed')
      expect(connection).to receive(:close)

      expect { described_class.new(access).run! }.to raise_error('sync failed')
    end
  end

  describe 'unlisted partitions' do
    let(:cluster) { create(:cluster) }
    let(:project) { create(:project) }
    let(:access) { Core::Access.create!(project: project, cluster: cluster) }
    let(:connection) { double('ssh connection', close: nil) }
    let(:partitions) { cluster.partitions.order(:id).to_a }
    let(:listed_partition) { partitions.first }
    let(:default_partition) { partitions.second }
    let(:non_default_partition) { partitions.third }
    let(:sync_calls) { [] }

    before do
      create(:resource_control,
             access: access,
             resource_control_partitions: [
               Core::ResourceControlPartition.new(partition: listed_partition)
             ])
      default_partition.update!(default: true)
      allow(Net::SSH).to receive(:start).and_return(connection)
      allow_any_instance_of(Core::ResourceControl).to receive(:synchronize)
      allow(access).to receive(:sync_partition_access) do |partition, max_submit, max_jobs, ssh|
        sync_calls << [partition.id, max_submit, max_jobs, ssh]
      end
    end

    it 'blocks every unlisted partition when denying unlisted partitions' do
      access.update!(deny_unlisted_partitions: true)

      described_class.new(access).run_resource_controls!

      expect(sync_calls.map(&:first)).to match_array(access.unlisted_partitions.pluck(:id))
      expect(sync_calls.map { |_id, max_submit, max_jobs, _ssh| [max_submit, max_jobs] })
        .to all(eq([0, 0]))
      expect(sync_calls.map(&:first)).not_to include(listed_partition.id)
    end

    it 'restores only unlisted default partitions when denying is disabled' do
      access.update!(deny_unlisted_partitions: false)

      described_class.new(access).run_resource_controls!

      expect(sync_calls.map { |id, max_submit, max_jobs, _ssh| [id, max_submit, max_jobs] })
        .to eq([[default_partition.id,
                 default_partition.max_submitted_jobs,
                 default_partition.max_running_jobs]])
    end

    it 'does not restore a listed default partition through the default path' do
      listed_partition.update!(default: true)
      access.update!(deny_unlisted_partitions: false)

      described_class.new(access).run_resource_controls!

      expect(sync_calls.map(&:first)).not_to include(listed_partition.id)
      expect(sync_calls.map(&:first)).to include(default_partition.id)
    end

    it 'does not restore a default partition listed in a pending control' do
      listed_partition.update!(default: true)
      expect(access.resource_controls.first).to be_pending
      access.update!(deny_unlisted_partitions: false)

      described_class.new(access).run_resource_controls!

      expect(sync_calls.map(&:first)).not_to include(listed_partition.id)
    end

    it 'does not block partitions when there are no controls and denying is disabled' do
      access.resource_controls.destroy_all
      access.update!(deny_unlisted_partitions: false)

      described_class.new(access).run_resource_controls!

      expect(sync_calls.map { |_id, max_submit, max_jobs, _ssh| [max_submit, max_jobs] })
        .not_to include([0, 0])
      expect(sync_calls.map(&:first)).to include(default_partition.id)
      expect(sync_calls.map(&:first)).not_to include(non_default_partition.id)
    end
  end
end
