#
module Core
  #
  # Notices controller
  #
  # @author [serg@parallel.ru]
  #
  class NoticesController < ApplicationController
    def index
      respond_to do |format|
        format.html do
          @my_notices = Notice.where(
            sourceable: current_user,
            category: Notice::PER_USER,
            active: 1
          )
          @site_wide_notices = Notice.where(
            category: Notice::SITE_WIDE,
            active: 1
          )
        end
      end
    end

    def change_visibility
      option = NoticeShowOption.find_or_initialize_by(
        user: current_user,
        notice_id: params[:id]
      )
      option.hidden = !option.hidden
      option.save!
      render :ok, plain: 'ok'
    end

    def hide
      option = NoticeShowOption.find_or_initialize_by(
        user: current_user,
        notice_id: params[:id]
      )
      option.hidden = !option.hidden
      option.save!
      redirect_to(params[:retpath] || [:admin, Notice])
    end

  end
end
