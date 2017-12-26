require 'test_helper'

module Jobstat
  class DigestStringDataControllerTest < ActionController::TestCase
    setup do
      @digest_string_datum = jobstat_digest_string_data(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:digest_string_data)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create digest_string_datum" do
      assert_difference('DigestStringDatum.count') do
        post :create, digest_string_datum: { name: @digest_string_datum.name, task_id: @digest_string_datum.task_id, time: @digest_string_datum.time, value: @digest_string_datum.value }
      end

      assert_redirected_to digest_string_datum_path(assigns(:digest_string_datum))
    end

    test "should show digest_string_datum" do
      get :show, id: @digest_string_datum
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @digest_string_datum
      assert_response :success
    end

    test "should update digest_string_datum" do
      patch :update, id: @digest_string_datum, digest_string_datum: { name: @digest_string_datum.name, task_id: @digest_string_datum.task_id, time: @digest_string_datum.time, value: @digest_string_datum.value }
      assert_redirected_to digest_string_datum_path(assigns(:digest_string_datum))
    end

    test "should destroy digest_string_datum" do
      assert_difference('DigestStringDatum.count', -1) do
        delete :destroy, id: @digest_string_datum
      end

      assert_redirected_to digest_string_data_path
    end
  end
end
