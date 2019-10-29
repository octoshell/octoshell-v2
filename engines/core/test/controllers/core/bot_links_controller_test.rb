require 'test_helper'

module Core
  class BotLinksControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @bot_link = core_bot_links(:one)
    end

    test "should get index" do
      get bot_links_url
      assert_response :success
    end

    test "should get new" do
      get new_bot_link_url
      assert_response :success
    end

    test "should create bot_link" do
      assert_difference('BotLink.count') do
        post bot_links_url, params: { bot_link: { active: @bot_link.active, token: @bot_link.token, user_id: @bot_link.user_id } }
      end

      assert_redirected_to bot_link_url(BotLink.last)
    end

    test "should show bot_link" do
      get bot_link_url(@bot_link)
      assert_response :success
    end

    test "should get edit" do
      get edit_bot_link_url(@bot_link)
      assert_response :success
    end

    test "should update bot_link" do
      patch bot_link_url(@bot_link), params: { bot_link: { active: @bot_link.active, token: @bot_link.token, user_id: @bot_link.user_id } }
      assert_redirected_to bot_link_url(@bot_link)
    end

    test "should destroy bot_link" do
      assert_difference('BotLink.count', -1) do
        delete bot_link_url(@bot_link)
      end

      assert_redirected_to bot_links_url
    end
  end
end
