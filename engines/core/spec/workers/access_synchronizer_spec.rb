require 'main_spec_helper'

RSpec.describe AccessSynchronizer do
  let(:access) { create(:core_access) }

  describe '#perform' do
    it 'runs a full access synchronization by default' do
      expect_any_instance_of(Core::Access).to receive(:synchronize!)

      described_class.new.perform(access.id)
    end

    it 'runs a resource controls synchronization for the resource_controls scope' do
      expect_any_instance_of(Core::Access).to receive(:synchronize_resource_controls!)

      described_class.new.perform(access.id, :resource_controls)
    end

    it 're-enqueues the job when the access lock times out' do
      allow_any_instance_of(Core::Access).to receive(:synchronize_resource_controls!)
        .and_raise(RedisMutex::LockError)
      expect(described_class).to receive(:perform_in)
        .with(described_class::RETRY_DELAY, access.id, :resource_controls)

      described_class.new.perform(access.id, :resource_controls)
    end
  end
end
