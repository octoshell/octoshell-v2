require_dependency "api/admin/application_controller"

module Api::Admin
  class ExportsController < Api::Admin::ApplicationController
    before_action :set_export, only: [:show, :edit, :update, :destroy]
    before_action :authorize_admins
    def authorize_admins
      authorize!(:manage, :api_engine)
    end

    # GET /exports
    def index
      @exports = Export.all
    end

    # GET /exports/1
    def show
    end

    # GET /exports/new
    def new
      @export = Export.new
    end

    # GET /exports/1/edit
    def edit
    end

    # POST /exports
    def create
      par = export_params
      @export = Export.new(par)

      if @export.save
        redirect_to admin_exports_url, notice: 'Export was successfully created.'
        #[:admin, @export]
      else
        render :new
      end
    end

    # PATCH/PUT /exports/1
    def update
      if @export.update(export_params)
        redirect_to admin_exports_url, notice: 'Export was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /exports/1
    def destroy
      @export.destroy
      redirect_to admin_exports_url, notice: 'Export was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_export
        @export = Export.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def export_params
        params.require(:export).permit(:title, :request, :text, :safe, :access_key_ids=>[], :key_parameters => [])
      end
  end
end
