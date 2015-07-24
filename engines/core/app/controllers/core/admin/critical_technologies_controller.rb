module Core
  class Admin::CriticalTechnologiesController < Admin::ApplicationController
    def index
      @critical_technologies = CriticalTechnology.order(:name)
    end

    def new
      @critical_technology = CriticalTechnology.new
    end

    def create
      @critical_technology = CriticalTechnology.new(critical_technology_params)
      if @critical_technology.save
        redirect_to admin_critical_technologies_path
      else
        render :new
      end
    end

    def edit
      @critical_technology = CriticalTechnology.find(params[:id])
    end

    def update
      @critical_technology = CriticalTechnology.find(params[:id])
      if @critical_technology.update_attributes(critical_technology_params)
        redirect_to admin_critical_technologies_path
      else
        render :edit
      end
    end

    def destroy
      @critical_technology = CriticalTechnology.find(params[:id])
      @critical_technology.destroy
      redirect_to admin_critical_technologies_path
    end
  end

  private
  def critical_technology_params
    params.require(:critical_technology).permit(:name)
  end
end
