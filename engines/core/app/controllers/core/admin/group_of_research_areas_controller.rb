module Core
  class Admin::GroupOfResearchAreasController < Admin::ApplicationController
    before_action :octo_authorize!


    def new
      @group_of_research_area = GroupOfResearchArea.new
    end

    def create
      @group_of_research_area = GroupOfResearchArea.new(research_area_params)
      if @group_of_research_area.save
        redirect_to admin_research_areas_path
      else
        render :new
      end
    end

    def edit
      @group_of_research_area = GroupOfResearchArea.find(params[:id])
    end

    def update
      @group_of_research_area = GroupOfResearchArea.find(params[:id])
      if @group_of_research_area.update_attributes(research_area_params)
        @group_of_research_area.save
        redirect_to admin_research_areas_path
      else
        render :edit
      end
    end

    def destroy
      @group_of_research_area = GroupOfResearchArea.find(params[:id])
      @group_of_research_area.destroy
      redirect_to admin_research_areas_path
    end

    private

    def research_area_params
      params.require(:group_of_research_area).permit(*GroupOfResearchArea.locale_columns(:name))
    end
  end
end
