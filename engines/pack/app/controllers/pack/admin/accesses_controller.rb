require_dependency "pack/application_controller"
# require "#{Pack::Engine.root}/app/services/pack/admin_access_updater"
module Pack
  class Admin::AccessesController < Admin::ApplicationController
    rescue_from ActiveRecord::RecordNotFound do |ex|
      render "not_found"
    end
    before_action :access_init, only: [:edit, :show,:update,:destroy, :manage_access]
    def access_init
      @access = Access.preload_who.find(params[:id])
    end

    def index
      @q = Access.ransack(params[:q])
      @accesses = @q.result(distinct: true).order(:id).page(params[:page]).per(10).preload_who.includes(:version)
    end

    def show
      edit_options
    end

    def manage_access
      if @access.lock_version_updated?(params[:lock_version])
        # flash[:error] = t('pack.access.updated_during_edit_static')
        redirect_to :show, error: t('pack.access.updated_during_edit_static')
      else
        @access.admin_update current_user, params_without_hash
        redirect_to [:admin, @access]
      end
    end

    def new
      @access = Access.new
      @access.who_type="User"
    end

    def create
      @access = Access.new access_params.except(:forever)
      if access_params[:forever] == 'true'
        @access.end_lic = nil
        @access.new_end_lic = nil
        @access.new_end_lic_forever = false
      elsif access_params[:end_lic] == ''
        @access.errors.add(:end_lic,:blank_not_forever)
        render :new
        return
      end
      @access.created_by_id = current_user.id
      @access.allowed_by_id = current_user.id if @access.status=='allowed'
      if @access.save
        redirect_to admin_access_path(@access)
      else
        render :new
      end
    end

    def edit; end

    def update
      if access_params[:forever] == 'true'
        @access.end_lic = nil
        @access.new_end_lic = nil
        @access.new_end_lic_forever = false
      elsif access_params[:end_lic] == ''
        @access.errors.add(:end_lic,:blank_not_forever)
        render :new
        return
      end
      @access.allowed_by_id = current_user.id if @access.changes[:status] && @access.status=='allowed'
      if @access.update(access_params)
        redirect_to admin_access_path(@access.id)
      else
        render :edit
      end
    end

    def get_groups
      respond_to do |format|
      format.json do
        @records = Group.where("lower(name) like lower(:q)", q: "%#{params[:q].mb_chars}%")
        render json: { records: @records.page(params[:page])
          .per(params[:per]).map{ |v|  {text: v.name, id: v.id}  }, total: @records.count }
      end
     end
    end


    def destroy
      @access.destroy
      redirect_to admin_accesses_path
    end

    private


    def edit_options
      @options_for_select = @access.actions
      @options_for_select_labels = @access.actions_labels
    end

    def params_without_hash
      params.permit(:forever, :lock_version, :version_id,
                    :status, :approve, :delete_request,
                    :end_lic)
    end

  	def access_params
      params.require(:access).permit(:who_id,:forever,:action,:lock_version,:proj_or_user, :version_id,
        :new_end_lic, :new_end_lic_forever, :end_lic,:status,:user_id,:project_id,:who_type)
    end

  end
end
