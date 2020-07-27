require "application_system_test_case"

module Core
  class BotLinksTest < ApplicationSystemTestCase
    setup do
      @bot_link = core_bot_links(:one)
    end

    test "visiting the index" do
      visit bot_links_url
      assert_selector "h1", text: "Bot Links"
    end

    test "creating a Bot link" do
      visit bot_links_url
      click_on "New Bot Link"

      check "Active" if @bot_link.active
      fill_in "Token", with: @bot_link.token
      fill_in "User", with: @bot_link.user_id
      click_on "Create Bot link"

      assert_text "Bot link was successfully created"
      click_on "Back"
    end

    test "updating a Bot link" do
      visit bot_links_url
      click_on "Edit", match: :first

      check "Active" if @bot_link.active
      fill_in "Token", with: @bot_link.token
      fill_in "User", with: @bot_link.user_id
      click_on "Update Bot link"

      assert_text "Bot link was successfully updated"
      click_on "Back"
    end

    test "destroying a Bot link" do
      visit bot_links_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Bot link was successfully destroyed"
    end
  end
end
