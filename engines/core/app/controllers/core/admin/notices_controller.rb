module Core
  class Admin::NoticesController < Admin::ApplicationController
    load_and_authorize_resource :class => "Core::Notice", except: [:show, :hide]

    def index
      par = notice_params
      respond_to do |format|
        format.html do
          @search = Notice.search(par[:q])
          search_result = @search.result(distinct: true).order(:id)
          @notices = search_result
          without_pagination :notices
        end
        format.json do
          @notices = Notice.search(par[:q])
          json = { records: @notices.page(par[:page]).per(par[:per]), total: @notices.count }
          render json: json
        end
      end
    end

    def new
      par = notice_params
      @notice = Notice.new
      @notice.sourceable_id = par[:sourceable_id]
      @notice.sourceable_type = par[:sourceable_type]
      @notice.linkable_id = par[:linkable_id] if par[:linkable_id]
      @notice.linkable_type = par[:linkable_type] if par[:linkable_type]
      @notice.category = par[:category].to_i
      @notice.message = par[:message]
      @notice.count = par[:count].to_i
    end

    def create
      par = notice_params
      @notice = Notice.new
      @notice.sourceable_id = par[:sourceable_id]
      @notice.sourceable_type = par[:sourceable_type]
      @notice.linkable_id = par[:linkable_id] if par[:linkable_id]
      @notice.linkable_type = par[:linkable_type] if par[:linkable_type]
      @notice.category = par[:category].to_i
      @notice.message = par[:message]
      @notice.count = par[:count].to_i
      if @notice.save
        redirect_to [:admin, @notice]
      else
        render :new
      end
    end

    def show
      par = notice_params
      @notice = Notice.find(par[:id])
    end

    def edit
      par = notice_params
      @notice = Notice.find(par[:id])
    end

    def update
      par = notice_params
      @notice = Notice.find(par[:id])
      if @notice.update notice_par
        redirect_to [:admin, @notice]
      else
        render :edit
      end
    end

    def destroy
      par = notice_params
      @notice = Notice.find_by_id(par[:id])
      if @notice
        @notice.destroy
      end
      if par[:retpath]
        redirect_to par[:retpath]
      else
        redirect_to [:admin, Notice]
      end
    end


    def hide
      par = notice_params
      #logger.warn "=== #{params.inspect}"
      @notice = Notice.find_by_id(par[:notice_id])
      if @notice
        if can?(:manage, :notices) or (@notice.category==0 && notice.sourceable==current_user)
          # logger.warn "==================================== No destroy #{@notice.id} (#{par[:retpath]})"
          @notice.active = false
          @notice.save
        end
      end
      if par[:retpath]
        redirect_to par[:retpath]
      else
        redirect_to [:admin, Notice]
      end
    end

    private

    def notice_params
      params.permit(:id,:notice_id, :category
        :sourceable_id, :sourceable_type,
        :linkable_id, :linkable_type,
        :type, :message, :count, :retpath
        )
    end
  end
end
