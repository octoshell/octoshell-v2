require "spec_helper"

describe User do
  subject(:user) { User.create!(email: "basya@bulat.com", password: "123456") }

  describe "#create" do
    it { expect(user).not_to be_activated }

    describe "validations" do
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email) }

      it { should ensure_length_of(:password).is_at_least(6) }
    end
  end

  describe "mail sending" do
    it "sends activation mail" do
      expect(Authentication::MailWorker).to have_enqueued_job(:activation_needed,
                                                              [user.email, user.activation_token])
    end

    it "sends activation success mail" do
      user.activate!
      expect(Authentication::MailWorker).to have_enqueued_job(:activation_success, user.email)
    end


    it "sends reset password email" do
      user.deliver_reset_password_instructions!
      expect(Authentication::MailWorker).to have_enqueued_job(:reset_password,
                                                              [user.email, user.reset_password_token])
    end
  end
end
