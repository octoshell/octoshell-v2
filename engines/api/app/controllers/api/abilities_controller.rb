require_dependency "api/application_controller"

module Api
  class AbilitiesController < ApplicationController
    before_action :set_ability, only: [:show, :edit, :update, :destroy]

    # GET /abilities
    def index
      @abilities = Ability.all
    end

    # GET /abilities/1
    def show
    end

    # GET /abilities/new
    def new
      @ability = Ability.new
    end

    # GET /abilities/1/edit
    def edit
    end

    # POST /abilities
    def create
      @ability = Ability.new(ability_params)

      if @ability.save
        redirect_to @ability, notice: 'Ability was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /abilities/1
    def update
      if @ability.update(ability_params)
        redirect_to @ability, notice: 'Ability was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /abilities/1
    def destroy
      @ability.destroy
      redirect_to abilities_url, notice: 'Ability was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ability
        @ability = Ability.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ability_params
        params.require(:ability).permit(:key)
      end
  end
end
