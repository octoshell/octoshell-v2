require 'test_helper'

module Pack
  class UserversControllerTest < ActionController::TestCase
    setup do
      @userver = pack_uservers(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:uservers)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create userver" do
      assert_difference('Userver.count') do
        post :create, userver: {  }
      end

      assert_redirected_to userver_path(assigns(:userver))
    end

    test "should show userver" do
      get :show, id: @userver
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @userver
      assert_response :success
    end

    test "should update userver" do
      patch :update, id: @userver, userver: {  }
      assert_redirected_to userver_path(assigns(:userver))
    end

    test "should destroy userver" do
      assert_difference('Userver.count', -1) do
        delete :destroy, id: @userver
      end

      assert_redirected_to uservers_path
    end
  end
end
