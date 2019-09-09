module Core
  class Admin::DirectionOfSciencesController < Admin::ApplicationController
    before_action :octo_authorize!
    def index
      @direction_of_sciences = DirectionOfScience.order(DirectionOfScience.current_locale_column(:name))
    end

    def new
      @direction_of_science = DirectionOfScience.new
    end

    def create
      @direction_of_science = DirectionOfScience.new(direction_of_science_params)
      if @direction_of_science.save
        redirect_to admin_direction_of_sciences_path
      else
        render :new
      end
    end

    def edit
      @direction_of_science = DirectionOfScience.find(params[:id])
    end

    def update
      @direction_of_science = DirectionOfScience.find(params[:id])
      if @direction_of_science.update_attributes(direction_of_science_params)
        @direction_of_science.save
        redirect_to admin_direction_of_sciences_path
      else
        render :edit
      end
    end

    def destroy
      @direction_of_science = DirectionOfScience.find(params[:id])
      @direction_of_science.destroy
      redirect_to admin_direction_of_sciences_path
    end

    private
    def direction_of_science_params
      params.require(:direction_of_science).permit(*DirectionOfScience.locale_columns(:name))
    end
  end
end
