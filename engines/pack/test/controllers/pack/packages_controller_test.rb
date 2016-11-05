require 'test_helper'

module Pack
  class PackagesControllerTest < ActionController::TestCase
    setup do
      @package = pack_packages(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:packages)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create package" do
      assert_difference('Package.count') do
        post :create, package: { name: @package.name }
      end

      assert_redirected_to package_path(assigns(:package))
    end

    test "should show package" do
      get :show, id: @package
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @package
      assert_response :success
    end

    test "should update package" do
      patch :update, id: @package, package: { name: @package.name }
      assert_redirected_to package_path(assigns(:package))
    end

    test "should destroy package" do
      assert_difference('Package.count', -1) do
        delete :destroy, id: @package
      end

      assert_redirected_to packages_path
    end
  end
end
