require 'test_helper'

module Wiki
  class TasksControllerTest < ActionController::TestCase
    setup do
      @task = wiki_tasks(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:tasks)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create task" do
      assert_difference('Task.count') do
        post :create, task: { account: @task.account, task_id: @task.task_id }
      end

      assert_redirected_to task_path(assigns(:task))
    end

    test "should show task" do
      get :show, id: @task
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @task
      assert_response :success
    end

    test "should update task" do
      patch :update, id: @task, task: { account: @task.account, task_id: @task.task_id }
      assert_redirected_to task_path(assigns(:task))
    end

    test "should destroy task" do
      assert_difference('Task.count', -1) do
        delete :destroy, id: @task
      end

      assert_redirected_to tasks_path
    end
  end
end
