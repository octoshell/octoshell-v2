require 'main_spec_helper'

module Core
  RSpec.describe Partition do
    it 'requires job limits for default partitions' do
      partition = build(:partition, default: true)

      expect(partition).not_to be_valid
      expect(partition.errors[:max_submitted_jobs]).to be_present
      expect(partition.errors[:max_running_jobs]).to be_present
    end

    it 'allows default partitions with job limits' do
      expect(build(:partition, :default)).to be_valid
    end

    it 'does not require job limits for non-default partitions' do
      expect(build(:partition, default: false)).to be_valid
    end
  end
end
