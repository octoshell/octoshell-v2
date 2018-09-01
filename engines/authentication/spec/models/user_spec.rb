require 'main_spec_helper'

RSpec.describe User, type: :model do
  subject(:user) { User.create!(email: "basya@bulat.com", password: "123456") }

  describe "#create" do
    it { expect(user).not_to be_activated }

    describe "validations" do
      it { should validate_presence_of(:email) }
      # it { should validate_uniqueness_of(:email) }

      # it { should ensure_length_of(:password).is_at_least(6) }
    end
  end

  describe "mail sending" do
    it "sends activation mail" do
      # puts ActionMailer::Base.deliveries.inspect
      # expect(Authentication::MailerWorker).to have_enqueued_sidekiq_job(:activation_needed,
      #                                                         [user.email, user.activation_token])

    end

    it "sends activation success mail" do
      user.activate!
      expect(ActionMailer::Base.deliveries.last).to have_attributes(to: ['basya@bulat.com'],subject: 'Активация прошла успешно')
      # expect(Authentication::MailerWorker).to have_enqueued_sidekiq_job(:activation_success, user.email)
    end


    it "sends reset password email" do
      user.deliver_reset_password_instructions!
      expect(ActionMailer::Base.deliveries.last).to have_attributes(to: ['basya@bulat.com'],subject: 'Восстановление пароля')
      # expect(Authentication::MailerWorker).to have_enqueued_sidekiq_job(:reset_password,
      #                                                         [user.email, user.reset_password_token])
    end

    it 'deletes pending old users' do
      # Authentication.delete_after = 6.months
      user = create(:unactivated_user, created_at: Date.today - 12.months, activation_state: :pending)
      User.delete_pending_users
      expect(User.exists?(user)).to eq false
    end

    it 'deletes only old pending users' do
      # Authentication.delete_after = 6.months
      user = create(:unactivated_user, created_at: Date.today - 4.months, activation_state: :pending)
      user2 = create(:user, created_at: Date.today - 12.months, activation_state: :pending)

      User.delete_pending_users
      expect(User.exists?(user)).to eq true
      expect(User.exists?(user2)).to eq true
    end

  end
end
