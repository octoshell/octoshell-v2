module Authentication
  class Mailer < ActionMailer::Base
    def activation_needed(email, activation_token)
      @activation_token = activation_token
      mail to: email
    end

    def activation_success(email)
      mail to: email
    end

    def reset_password(email, reset_password_token)
      @reset_password_token = reset_password_token
      mail to: email
    end
  end
end
