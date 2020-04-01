module Core
  class Admin::NoticesController < Admin::ApplicationController
    def index
      respond_to do |format|
        format.html do
          @search = Notice.search(params[:q])
          search_result = @search.result(distinct: true).order(:id)
          @notices = search_result
          without_pagination :notices
        end
        format.json do
          @notices = Notice.search(params[:q])
          json = { records: @notices.page(params[:page]).per(params[:per]), total: @notices.count }
          render json: json
        end

      end
    end

    def new
      @notice = Notice.new
      @notice.sourceable_id = params[:sourceable_id]
      @notice.sourceable_type = params[:sourceable_type]
      @notice.linkable_id = params[:linkable_id] if params[:linkable_id]
      @notice.linkable_type = params[:linkable_type] if params[:linkable_type]
      @notice.category = params[:category].to_i
      @notice.message = params[:message]
      @notice.count = params[:count].to_i
    end

    def create
      if can? :manage, :notices
        @notice = Notice.new
        @notice.sourceable_id = params[:sourceable_id]
        @notice.sourceable_type = params[:sourceable_type]
        @notice.linkable_id = params[:linkable_id] if params[:linkable_id]
        @notice.linkable_type = params[:linkable_type] if params[:linkable_type]
        @notice.category = params[:category].to_i
        @notice.message = params[:message]
        @notice.count = params[:count].to_i
        if @notice.save
          redirect_to [:admin, @notice]
        else
          render :new
        end
      else
        redirect_to :notices
      end
    end

    def show
      @notice = Notice.find(params[:id])
    end

    def edit
      @notice = Notice.find(params[:id])
    end

    def update
      @notice = Notice.find(params[:id])
      if @notice.update notice_params
        redirect_to [:admin, @notice]
      else
        render :edit
      end
    end

    def destroy
      @notice = Notice.find_by_id(params[:id])
      if @notice
        if can? :manage, :notices
          @notice.destroy
          if params[:retpath]
            redirect_to params[:retpath]
          else
            redirect_to [:admin, Notice]
          end
        else
          # cannot destroy... Just hide it.
          logger.warn "==================================== No destroy #{@notice.id}"
          @notice.active = false
          @notice.save
          if params[:retpath]
            redirect_to params[:retpath]
          else
            redirect_to [:admin, Notice]
          end
        end
      end
    end

    private

    def notice_params
      params.require(:notice).permit(
        :sourceable_id, :sourceable_type,
        :linkable_id, :linkable_type,
        :type, :message, :count, :retpath
        )
    end
  end
end
