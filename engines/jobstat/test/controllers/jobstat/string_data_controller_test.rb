require 'test_helper'

module Jobstat
  class StringDataControllerTest < ActionController::TestCase
    setup do
      @string_datum = jobstat_string_data(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:string_data)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create string_datum" do
      assert_difference('StringDatum.count') do
        post :create, string_datum: { name: @string_datum.name, task_id: @string_datum.task_id, value: @string_datum.value }
      end

      assert_redirected_to string_datum_path(assigns(:string_datum))
    end

    test "should show string_datum" do
      get :show, id: @string_datum
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @string_datum
      assert_response :success
    end

    test "should update string_datum" do
      patch :update, id: @string_datum, string_datum: { name: @string_datum.name, task_id: @string_datum.task_id, value: @string_datum.value }
      assert_redirected_to string_datum_path(assigns(:string_datum))
    end

    test "should destroy string_datum" do
      assert_difference('StringDatum.count', -1) do
        delete :destroy, id: @string_datum
      end

      assert_redirected_to string_data_path
    end
  end
end
