# encoding: utf-8

require "spec_helper"

feature "Signing up", js: true do
  scenario "activated user" do
    user = seed(:user)
    sign_in(user)
    expect(page).to have_content("Выход")
  end

  scenario "unactivated user" do
    user = seed(:unactivated_user)
    sign_in(user)
    expect(page.find(".flash-message")).to have_content(I18n.t("activerecord.errors.models.user.attributes.base.user_is_not_activated"))
  end

  scenario "unregistered user" do
    sign_in_with "john@doe.com", "111111"
    expect(page.find(".flash-message")).to have_content(I18n.t("activerecord.errors.models.user.attributes.base.user_is_not_registered"))
  end

  scenario "user inputs wrong password" do
    user = seed(:user)
    sign_in_with user.email, "111111"
    expect(page.find(".flash-message")).to have_content(I18n.t("activerecord.errors.models.user.attributes.base.wrong_password"))
  end
end
