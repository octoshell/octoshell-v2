module Authentication
  module UserWithAuthErrors
    def initialize_with_auth_errors(email)
      auth = User.new(email: email)
      if user = User.find_by_email(email)
        auth.errors.add :base, extract_error(user)
      else
        auth.errors.add :base, :user_is_not_registered
      end
      auth
    end

    private

    def extract_error(user)
      if user.activation_pending?
        :user_is_not_activated
      else
        :wrong_password
      end
    end
  end
end
