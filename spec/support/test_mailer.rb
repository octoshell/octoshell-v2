  class TestMailer < ActionMailer::Base
    def test_mail(emails)
      mail to: emails, subject: 'TEST MAIL', body: 'ACTIONMAILER'
    end
  end
