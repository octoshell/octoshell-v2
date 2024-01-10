module Core
  class Admin::NoticesController < Admin::ApplicationController
    before_action :check_auth

    def check_auth
      can? :manage, :notices
    end

    def index
      respond_to do |format|
        format.html do
          @search = Notice.ransack(params[:q] || { category_in: [0] })
          @notices = @search.result(distinct: true).order(id: :desc)
        end
        format.json do
          @users = User.finder(params[:q])
          render json: { records: @users.page(params[:page]).per(params[:per]),
                         total: @users.count }
        end
      end
    end

    def new
      @notice = Notice.new
      @notice.active = false
    end

    def create
      category_alt = params[:notice].delete(:category_alt)
      @notice = Notice.new(notice_params)
      @notice.category = category_alt if category_alt.present?
      @notice.sourceable_type = User if @notice.sourceable_id.present?
      if @notice.save
        flash_message :info, t('.notice_succeed')
        redirect_to [:admin, @notice]
      else
        flash_message :info, t('.notice_failed')
        render :new
      end
    end

    def show
      @notice = Notice.find(params[:id])
    end

    def edit
      @notice = Notice.find(params[:id])
    end

    def update
      category_alt = params[:notice].delete(:category_alt)
      @notice = Notice.find(params[:id])
      @notice.category = category_alt if category_alt.present?
      @notice.sourceable_type = User if @notice.sourceable_id.present?
      if @notice.update notice_params
        redirect_to [:admin, @notice]
      else
        render :edit
      end
    end

    def destroy
      @notice = Notice.find(params[:id])
      redirect_to [:admin, Notice]
    end

    private

    def notice_params
      params.require(:notice).permit(:sourceable_id, :sourceable_type,
                                     :linkable_id, :linkable_type,
                                     :kind, :message, :count,
                                     :show_till, :show_from,
                                     :category, :active)
    end
  end
end
