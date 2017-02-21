require_dependency "jd/application_controller"
require 'benchmark'

module Jd
  class ProjectStatController < ApplicationController
    def show()
      # controller for project stat page
      @project = Core::Project.find(params[:id])
      @accounts = @project.members.map { |item| item.login }

      @t_from = nil
      @t_to = nil

      @systems = @@systems

      @user_stat = get_users_stat(@accounts, @t_from, @t_to)
      @system_stat = get_system_stat(@user_stat)

      render :show
    end

    def query()
      # controller for project stat page
      @project = Core::Project.find(params[:id])
      @accounts = @project.members.map { |item| item.login }

      @t_from = Time.strptime(params["request"].fetch("start_date"), "%Y-%m-%d").to_i
      @t_to = Time.strptime(params["request"].fetch("end_date"), "%Y-%m-%d").to_i

      @systems = @@systems

      @user_stat = get_users_stat(@accounts, @t_from, @t_to)
      @system_stat = get_system_stat(@user_stat)

      render :show
    end
  end
end
