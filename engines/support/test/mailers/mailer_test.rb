module Support
  class MailerTest < ActiveSupport::TestCase
    include ActionMailer::TestHelper
    include FactoryBot::Syntax::Methods

    def setup
      # do it before every test
    end

    def teardown
      # do this after every test
    end
     
    test "has anchor #reply on new ticket" do

      ticket = create(:ticket)
      
      email = Support::Mailer.send(:new_ticket, ticket.id)
      email.deliver_now!

      assert_match Regexp.new("href=\"http://\\S+/support/admin/tickets/#{ticket.id}#reply\""), email.body.to_s
    end
  end
end
