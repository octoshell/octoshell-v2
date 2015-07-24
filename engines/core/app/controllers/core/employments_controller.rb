module Core
  class EmploymentsController < ApplicationController
    before_filter :require_login

    def new
      @employment = current_user.employments.build do |employment|
        hash = employment_params
        if hash && hash[:organization_id].present?
          employment.organization = Organization.find(hash[:organization_id])
        end
      end
      @employment.build_default_positions
    end

    def create
      @employment = current_user.employments.build(employment_params)
      if @employment.save
        redirect_to main_app.profile_path
      else
        @employment.build_default_positions
        render :new
      end
    end

    def show
      @employment = Employment.find(params[:id])
      @employment.build_default_positions
    end

    def update
      @employment = current_user.employments.find(params[:id])
      if @employment.update(employment_params)
        redirect_to main_app.profile_path
      else
        @employment.build_default_positions
        render :show
      end
    end

    def destroy
      @employment = current_user.employments.find(params[:id])
      @employment.deactivate!
      redirect_to main_app.profile_path
    end

    private

    def employment_params
      if params[:employment].present?
        params.require(:employment).permit(:organization_id,
                                           :organization_department_id,
                                           :organization_department_name,
                                           :primary,
                                           positions_attributes: [:id, :name, :value])
      else
        {}
      end
    end
  end
end
