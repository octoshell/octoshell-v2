require 'main_spec_helper'

module Support
  RSpec.describe 'Ticket notifications', type: :mailer do
    include ActionMailer::TestHelper

    let(:support_user) { create_support }
    let(:reporter) { create(:user) }
    let(:topic) { create(:topic, visible_on_create: true) }

    before do
      support_user # create support user
      reporter     # create reporter (sends welcome email)
      topic        # create topic
      ActionMailer::Base.deliveries.clear
    end

    describe 'creating ticket from admin panel' do
      it 'does not send notification to support users (admins)' do
        create(:ticket, topic: topic, reporter: reporter, created_from_admin: true)

        emails = ActionMailer::Base.deliveries
        admin_emails = emails.select { |e| e.to.include?(support_user.email) }
        expect(admin_emails).to be_empty
      end

      it 'sends notification to the ticket author (reporter)' do
        create(:ticket, topic: topic, reporter: reporter, created_from_admin: true)

        emails = ActionMailer::Base.deliveries
        reporter_emails = emails.select { |e| e.to.include?(reporter.email) }
        expect(reporter_emails).not_to be_empty
      end

      it 'sends notification only to author, not to admin' do
        create(:ticket, topic: topic, reporter: reporter, created_from_admin: true)

        emails = ActionMailer::Base.deliveries
        all_recipients = emails.flat_map(&:to).flatten

        expect(all_recipients).to include(reporter.email)
        expect(all_recipients).not_to include(support_user.email)
      end
    end

    describe 'creating ticket from user panel' do
      it 'sends notification to support users (admins) but not to reporter' do
        create(:ticket, topic: topic, reporter: reporter)

        emails = ActionMailer::Base.deliveries
        admin_emails = emails.select { |e| e.to.include?(support_user.email) }
        reporter_emails = emails.select { |e| e.to.include?(reporter.email) }

        expect(admin_emails).not_to be_empty
        expect(reporter_emails).to be_empty
      end
    end
  end
end
