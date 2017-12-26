require 'test_helper'

module Jobstat
  class JobsControllerTest < ActionController::TestCase
    setup do
      @job = jobstat_jobs(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:jobs)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create job" do
      assert_difference('Job.count') do
        post :create, job: { account: @job.account, alloc_cpus: @job.alloc_cpus, end_time: @job.end_time, job_id: @job.job_id, job_name: @job.job_name, login: @job.login, nodelist: @job.nodelist, partition: @job.partition, priority: @job.priority, req_cpus: @job.req_cpus, start_time: @job.start_time, state: @job.state, submit_time: @job.submit_time, timelimit: @job.timelimit }
      end

      assert_redirected_to job_path(assigns(:job))
    end

    test "should show job" do
      get :show, id: @job
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @job
      assert_response :success
    end

    test "should update job" do
      patch :update, id: @job, job: { account: @job.account, alloc_cpus: @job.alloc_cpus, end_time: @job.end_time, job_id: @job.job_id, job_name: @job.job_name, login: @job.login, nodelist: @job.nodelist, partition: @job.partition, priority: @job.priority, req_cpus: @job.req_cpus, start_time: @job.start_time, state: @job.state, submit_time: @job.submit_time, timelimit: @job.timelimit }
      assert_redirected_to job_path(assigns(:job))
    end

    test "should destroy job" do
      assert_difference('Job.count', -1) do
        delete :destroy, id: @job
      end

      assert_redirected_to jobs_path
    end
  end
end
