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
end
