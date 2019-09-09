require 'test_helper'

module Jobstat
  class FloatDataControllerTest < ActionController::TestCase
    setup do
      @float_datum = jobstat_float_data(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:float_data)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create float_datum" do
      assert_difference('FloatDatum.count') do
        post :create, float_datum: {name: @float_datum.name, job_id: @float_datum.job_id, value: @float_datum.value}
      end

      assert_redirected_to float_datum_path(assigns(:float_datum))
    end

    test "should show float_datum" do
      get :show, id: @float_datum
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @float_datum
      assert_response :success
    end

    test "should update float_datum" do
      patch :update, id: @float_datum, float_datum: {name: @float_datum.name, job_id: @float_datum.job_id, value: @float_datum.value}
      assert_redirected_to float_datum_path(assigns(:float_datum))
    end

    test "should destroy float_datum" do
      assert_difference('FloatDatum.count', -1) do
        delete :destroy, id: @float_datum
      end

      assert_redirected_to float_data_path
    end
  end
end
