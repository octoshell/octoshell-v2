require 'test_helper'

module Jobstat
  class DigestFloatDataControllerTest < ActionController::TestCase
    setup do
      @digest_float_datum = jobstat_digest_float_data(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:digest_float_data)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create digest_float_datum" do
      assert_difference('DigestFloatDatum.count') do
        post :create, digest_float_datum: { name: @digest_float_datum.name, job_id: @digest_float_datum.job_id, time: @digest_float_datum.time, value: @digest_float_datum.value }
      end

      assert_redirected_to digest_float_datum_path(assigns(:digest_float_datum))
    end

    test "should show digest_float_datum" do
      get :show, id: @digest_float_datum
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @digest_float_datum
      assert_response :success
    end

    test "should update digest_float_datum" do
      patch :update, id: @digest_float_datum, digest_float_datum: { name: @digest_float_datum.name, job_id: @digest_float_datum.job_id, time: @digest_float_datum.time, value: @digest_float_datum.value }
      assert_redirected_to digest_float_datum_path(assigns(:digest_float_datum))
    end

    test "should destroy digest_float_datum" do
      assert_difference('DigestFloatDatum.count', -1) do
        delete :destroy, id: @digest_float_datum
      end

      assert_redirected_to digest_float_data_path
    end
  end
end
