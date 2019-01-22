# encoding: utf-8

module Requests
  module Helpers
    def sign_in_with(email, password)
      visit authentication.new_session_path
      fill_in "Email", with: email
      fill_in "Пароль", with: password
      click_button "Войти"
    end

    def sign_in(user = nil)
      user ||= seed(:user)
      sign_in_with user.email, "123456"
    end

    def sign_out
      click_on "Выход"
    end
  end
end
