module Core
  class NoticesController < ApplicationController

    def index
      respond_to do |format|
        format.html do
          # @search = Notice.ransack(sourceable: current_user, category: 1, active: 1)
          # @my_notices = @search.result()
          @my_notices = Notice.where(sourceable: current_user, category: 1)

          # @search2 = Notice.ransack(category: 0, active: 1)
          # @site_wide_notices = @search2.result()
          @site_wide_notices = Notice.where(category: 0, active: 1)

          render :index
        end
        format.json do
          @my_notices = Notice.ransack(sourceable: current_user, category: 1, active: 1).includes(:notice_show_options)
          json = { records: @my_notices.page(par[:page]).per(par[:per]), total: @my_notices.count }

          @sw_notices = Notice.ransack(sourceable: current_user, category: 1, active: 1).includes(:notice_show_options)
          json[:records] << @sw_notices.page(par[:page]).per(par[:per])
          json[:total] += @sw_notices.count
          render json: json
        end
      end
    end

    def new
      npar = notice_params[:notice] || {}
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
      #"notice"=>{"id"=>"11", "show_from"=>"2020.04.03", "show_till"=>"2020.04.03",
      #  "linkable_id"=>"", "linkable_type"=>"", "category"=>"0", 
      #  "message"=>"тест тест, меня слышно?", "count"=>"21"}

      par = notice_params[:notice]
      category_alt = par.delete(:category_alt)
      par[:category] = category_alt.to_i if category_alt != ''
      par[:category] = par[:category].to_i

      # user = User.find_by_id(par[:sourceable_id])
      # logger.warn "User = #{user}"
      
      opts = {sourceable_type: 'User'}.merge par
      if category_alt != ''
        opts[:category] = category_alt.to_i
      end
      # logger.warn "-------------------------- #{@opts}"
      @notice = Notice.create(opts.reject{|k,v| v.nil?})
      
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
      if @notice && !can?(:manage, :notices)
        logger.warn "can - not!"
        if @notice.category == 0 && @notice.sourceable != current_user
          logger.warn "#{@notice.sourceable} != #{current_user}"
          # NOT SHOW
          @notice = nil
        end
      end
    end

    def edit
      par = notice_params
      @notice = Notice.find(par[:id])
    end

    def update
      par = notice_params[:notice]
      visible = par.delete('visible')
      category_alt = par.delete('category_alt')
      @notice = Notice.find(par[:id])
      par[:category] = category_alt.to_i if category_alt != ''
      par[:category] = par[:category].to_i
      # logger.warn "-------------------------- #{par}"
      if @notice.update par
        if visible != @notice.visible?
          # need to change visibility
          opt = Core::NoticeShowOption.find_or_create_by(user: current_user, notice: @notice)
          opt.hidden = !!visible
          opt.save
        end
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
        # if can?(:manage, :notices) or (@notice.category==0 && @notice.sourceable==current_user)
        #   # logger.warn "==================================== No destroy #{@notice.id} (#{par[:retpath]})"
        #   @notice.active = false
        #   @notice.save
        # end
        opt = ::Core::NoticeShowOption.find_or_create_by(user: current_user, notice: @notice)
        opt.hidden = true
        opt.save
      end
      if par[:retpath]
        redirect_to par[:retpath]
      else
        redirect_to [:admin, Notice]
      end
    end

    def visible
      # logger.warn "<<<<<<<<<<<< #{params.inspect}"
      par = notice_params
      @notice = Notice.find_by_id(par[:notice_id])
      updated = par[:visible].to_i == 0
      Core::Notice.mylog "visible=#{par[:visible]} #{par[:visible].to_i}"
      if @notice
        opt = ::Core::NoticeShowOption.find_or_create_by(user: current_user, notice: @notice)
        opt.hidden = updated
        opt.save
        Core::Notice.mylog "opt=#{opt.inspect} #{par[:visible].to_i}"
      end
      render json: {myupdate: updated ? 1 :0}
    end

    private

    def notice_params

      params.permit(:id, :notice_id, :category,
        :sourceable_id, :sourceable_type,
        :sourceable_id_eq, :sourceable_type_eq,
        :linkable_id, :linkable_type,
        :type, :message, :count, :retpath,
        :show_till, :show_from,
        :category_alt, :visible,
        :notice => [:id, :category,
          :category_alt, :kind,
          :visible,
          :active,
          :sourceable_id, :sourceable_type,
          :sourceable_id_eq, :sourceable_type_eq,
          :linkable_id, :linkable_type,
          :show_till, :show_from,
          :type, :message, :count],
        )
    end
  end
end
