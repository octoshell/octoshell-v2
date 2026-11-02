require 'main_spec_helper'

describe Core::Access do
  describe '#notification_interval_days' do
    it 'defaults to 7 days' do
      expect(described_class.new.notification_interval_days).to eq(7)
    end

    it 'accepts positive integer values' do
      [1, 3].each do |value|
        access = build(:core_access, notification_interval_days: value)

        expect(access).to be_valid
      end
    end

    it 'rejects zero, negative and non-integer values' do
      [0, -1, 1.5, nil].each do |value|
        access = build(:core_access, notification_interval_days: value)

        expect(access).not_to be_valid
      end
    end
  end

  describe '.due_for_resource_usage_notification' do
    let!(:access) { create(:core_access, notification_interval_days: 7) }

    it 'includes an access that has never been notified' do
      access.update_column(:last_notification_at, nil)

      expect(described_class.due_for_resource_usage_notification).to include(access)
    end

    it 'excludes an access before the interval passes' do
      access.update_column(:last_notification_at, 6.days.ago)

      expect(described_class.due_for_resource_usage_notification).not_to include(access)
    end

    it 'includes an access after the interval passes' do
      access.update_column(:last_notification_at, 8.days.ago)

      expect(described_class.due_for_resource_usage_notification).to include(access)
    end

    context 'with a one day interval' do
      before { access.update_column(:notification_interval_days, 1) }

      it 'includes an access after 22 hours' do
        access.update_column(:last_notification_at, 23.hours.ago)

        expect(described_class.due_for_resource_usage_notification).to include(access)
      end

      it 'excludes an access before 22 hours' do
        access.update_column(:last_notification_at, 21.hours.ago)

        expect(described_class.due_for_resource_usage_notification).not_to include(access)
      end
    end
  end
end
