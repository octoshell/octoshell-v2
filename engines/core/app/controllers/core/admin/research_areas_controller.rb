module Core
  class Admin::ResearchAreasController < Admin::ApplicationController
    before_action :octo_authorize!
    def index
      @groups = GroupOfResearchArea.order_by_name_with_areas
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
      if @research_area.update(research_area_params)
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
      params.require(:research_area).permit(*ResearchArea.locale_columns(:name), :group_id)
    end
  end
end
