require_dependency "jd/application_controller"
require 'benchmark'

module Jd
  class ProjectStatController < ApplicationController
    def show()
      # controller for project stat page
      @project = Core::Project.find(params[:id])
      @accounts = @project.members.map { |item| item.login }

      t_from = Time.strptime("2016-02-07", "%Y-%m-%d").to_i
      t_to = Time.now.to_i

      @systems = @@systems

      @user_stat = get_users_stat(@accounts, t_from, t_to)
      @system_stat = get_system_stat(@user_stat)

      render :show
    end
  end
end
