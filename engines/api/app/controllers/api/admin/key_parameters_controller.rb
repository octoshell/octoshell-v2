require_dependency "api/admin/application_controller"

module Api::Admin
  class KeyParametersController < ApplicationController
    before_action :set_key_parameters, only: [:show, :edit, :update, :destroy]
    before_action :authorize_admins
    def authorize_admins
      authorize!(:access, :api_engine)
    end

    # GET /key_parameters
    def index
      @key_parameters = KeyParameter.all
    end

    # GET /key_parameters/1
    def show
    end

    # GET /key_parameters/new
    def new
      @key_parameters = KeyParameter.new
    end

    # GET /key_parameters/1/edit
    def edit
    end

    # POST /key_parameters
    def create
      @key_parameters = KeyParameter.new(key_params)

      if @key_parameters.save
        redirect_to admin_key_parameters_url, notice: 'Param was successfully created.'
        #[:admin, @key_parameters]
      else
        render :new
      end
    end

    # PATCH/PUT /key_parameters/1
    def update
      if @key_parameters.update(key_params)
        redirect_to admin_key_parameters_url, notice: 'Param was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /key_parameters/1
    def destroy
      @key_parameters.destroy
      redirect_to admin_key_parameters_url, notice: 'Param was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_key_parameters
        @key_parameters = KeyParameter.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def key_params
        params.require(:key_parameter).permit(:name, :default, :export_ids=>[])
      end
  end
end
