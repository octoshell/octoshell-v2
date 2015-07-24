module Core
  class Admin::ResearchAreasController < Admin::ApplicationController
    def index
      @research_areas = ResearchArea.all
    end

    def new
      @research_area = ResearchArea.new
    end

    def create
      @research_area = ResearchArea.new(research_area_params)
      if @research_area.save
        redirect_to admin_research_areas_path
      else
        render :new
      end
    end

    def edit
      @research_area = ResearchArea.find(params[:id])
    end

    def update
      @research_area = ResearchArea.find(params[:id])
      if @research_area.update_attributes(research_area_params)
        redirect_to admin_research_areas_path
      else
        render :edit
      end
    end

    def destroy
      @research_area = ResearchArea.find(params[:id])
      @research_area.destroy
      redirect_to admin_research_areas_path
    end

    private
    def research_area_params
      params.require(:research_area).permit(:name, :group)
    end
  end
end
