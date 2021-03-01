require_dependency "cloud_computing/application_controller"

module CloudComputing
  class AccessesController < ApplicationController


    def prepare_to_finish
      @access = project_accesses.find(params[:id])
      authorize! :update, @access
      @access.prepare_to_finish!
      redirect_to @access
    end


    def index
      @search = project_accesses.search(params[:q])
      @accesses = @search.result(distinct: true)
                         .includes(:user, :allowed_by, :for)
                         .order(:created_at)
                         .page(params[:page])
                         .per(params[:per])
    end


    def show
      @access = project_accesses.find(params[:id])
    end

    def add_keys
      @access = project_accesses.find(params[:id])
      @access.add_keys
      redirect_to @access, flash: { info: t('.updated') }
    end

    private

    def project_accesses
      CloudComputing::Access.accessible_by(current_ability, :read)
    end

  end
end
