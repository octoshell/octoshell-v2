module Core
  class Admin::NoticesController < Admin::ApplicationController
    # load_and_authorize_resource :class => "Core::Notice", except: [:show, :hide, :index]
    # load_resource :class => "Core::Notice" #, except: [:show, :hide, :index]
    before_action :check_auth, except: [:show,:hide]

    def check_auth
      can? :manage, :notices
    end

    def index
      par = notice_params.to_hash
      par['notice'] ||= {}
      respond_to do |format|
        category = params[:category] ? params[:category] : 0
        par['notice'][:category] = category
        if par['notice'][:sourceable_id_enotice]
          par['notice'][:sourceable] = User.find_by_id par['notice'][:sourceable_id_enotice]
        end
        format.html do
          @search = Notice.search(par['notice'])
          search_result = @search.result() # distinct: true).order(:id)
          @notices = search_result
          # logger.warn  "------------------------------\n #{par['notice'].inspect}\n#{@notices.inspect}"
          without_pagination :notices
        end
        format.json do
          @notices = Notice.search(par['notice'])
          json = { records: @notices.page(par[:page]).per(par[:per]), total: @notices.count }
          render json: json
        end
      end
    end

    def new
      par = notice_params
      npar = par[:notice] || {}
      @notice = Notice.new
      @notice.sourceable_id = npar[:sourceable_id] if npar[:sourceable_id]
      @notice.sourceable_type = npar[:sourceable_type] if npar[:sourceable_type]
      @notice.linkable_id = npar[:linkable_id] if npar[:linkable_id]
      @notice.linkable_type = npar[:linkable_type] if npar[:linkable_type]
      @notice.category = npar[:category].to_i
      @notice.message = npar[:message]
      @notice.count = npar[:count].to_i if npar[:count]
    end

    def create
      par = notice_params
      # user = User.find_by_id(par[:notice][:sourceable_id])

      category_alt = par[:notice].delete(:category_alt)
      par[:category] = category_alt.to_i if category_alt != ''
      par[:category] = par[:category].to_i
      opts = { sourceable_type: 'User' }.merge par[:notice]
      @notice = Notice.create(opts.reject { |_, v| v.nil? })

      if @notice.save
        # logger.warn "***** #{@notice.inspect}"
        flash_message :info, t('.notice_succeed')
        redirect_to [:admin, @notice]
      else
        flash_message :info, t('.notice_failed')
        render :new
      end
    end

    def show
      par = notice_params
      @notice = Notice.find(par[:id])
      # logger.warn "Notice=#{@notice.inspect}"
      return unless @notice && !can?(:manage, :notices)
      # logger.warn "can - not!"
      return unless @notice.category.zero? && @notice.sourceable != current_user
      # logger.warn "#{@notice.sourceable} != #{current_user}"
      # NOT SHOW
      @notice = nil
    end

    def edit
      par = notice_params
      @notice = Notice.find(par[:id])
    end

    def update
      par = notice_params[:notice]
      category_alt = par.delete(:category_alt)
      par[:category] = category_alt.to_i if category_alt != ''
      par[:category] = par[:category].to_i
      @notice = Notice.find(par[:id])
      if @notice.update par
        redirect_to [:admin, @notice]
      else
        render :edit
      end
    end

    def destroy
      par = notice_params
      @notice = Notice.find_by_id(par[:id])
      @notice&.destroy
      if par[:retpath]
        redirect_to par[:retpath]
      else
        redirect_to [:admin, Notice]
      end
    end

    private

    def notice_params
      params.permit(
        :id, :notice_id, :category,
        :sourceable_id, :sourceable_type,
        :sourceable_id_eq, :sourceable_type_eq,
        :linkable_id, :linkable_type,
        :type, :message, :count, :retpath,
        :show_till, :show_from,
        :category_alt,
        :notice => [
          :id, :category,
          :sourceable_id, :sourceable_type,
          :sourceable_id_eq, :sourceable_type_eq,
          :linkable_id, :linkable_type,
          :show_till, :show_from,
          :type, :message, :count,
          :active, :category_alt, :kind,
          :category, :show_from_gt, :show_till_lt
        ]
      )
    end
  end
end
