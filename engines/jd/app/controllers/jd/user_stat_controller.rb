require_dependency "jd/application_controller"
require 'benchmark'

module Jd
  class UserStatController < ApplicationController
    def query_stat()
      # controller for job_table page

      @available_projects = get_available_projects(current_user)
      @selected_accounts = params.fetch("selected_accounts") & get_available_accounts(@available_projects)

      @t_from = Time.strptime(params["request"].fetch("start_date"), "%Y-%m-%d").to_i
      @t_to = Time.strptime(params["request"].fetch("end_date"), "%Y-%m-%d").to_i

      @systems = @@systems

      @user_stat = get_users_stat(@selected_accounts, @t_from, @t_to)
      @system_stat = get_system_stat(@user_stat)

      render :show_table
    end

    def show_stat()
      # controller for job_table page

      @available_projects = get_available_projects(current_user)
      @selected_accounts = get_available_accounts(@available_projects) # select all by default

      @systems = @@systems

      @user_stat = nil
      @system_stat = nil

      @t_from = nil
      @t_to = nil

      render :show_table
    end
  end
end
