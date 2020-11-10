module Octoface
  class Admin::RolesController < Admin::ApplicationController
    def index
      @roles = Octoface::OctoConfig.instances.values
    end

    def show
      @role = Octoface::OctoConfig.find_by_role(params[:name].to_sym)
    end
  end
end
