require_dependency "api/admin/application_controller"

module Api::Admin
  class AccessKeysController < Api::ApplicationController
    before_action :set_access_key, only: [:show, :edit, :update, :destroy]
    before_action :authorize_admins
    def authorize_admins
      authorize!(:manage, :api_engine)
    end

    # GET /access_keys
    def index
      @access_keys = Api::AccessKey.all
    end

    # GET /access_keys/1
    def show
    end

    # GET /access_keys/new
    def new
      @access_key = Api::AccessKey.new
    end

    # GET /access_keys/1/edit
    def edit
    end

    # POST /access_keys
    def create
      @access_key = Api::AccessKey.new(access_keys_params)

      if @access_key.save
        redirect_to admin_access_keys_url, notice: 'Access key was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /access_keys/1
    def update
      if @access_key.update(access_keys_params)
        redirect_to admin_access_keys_url, notice: 'Access key was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /access_keys/1
    def destroy
      @access_key.destroy
      redirect_to admin_access_keys_url, notice: 'Access key was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_access_key
        @access_key = Api::AccessKey.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def access_keys_params
        params.require(:access_key).permit(:key,:export_ids=>[])
      end
  end
end
