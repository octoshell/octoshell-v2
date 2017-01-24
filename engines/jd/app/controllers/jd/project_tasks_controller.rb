require_dependency "jd/application_controller"

module Jd
  class ProjectTasksController < ApplicationController
    def show_table()
      project_id = params[:project_id]

      accounts = ["fgg"]

      accounts.concat(get_accounts)

      @jobs = []

      url = @@host + "/api/account/"

      accounts.each do |account|
        open(url + account) do |io|
          @jobs.concat(JSON.parse(io.read))
        end
      end

      render :show_table
    end
  end
end
