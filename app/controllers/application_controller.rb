class ApplicationController < ActionController::Base

  before_action :set_paper_trail_whodunnit

  def info_for_paper_trail
    { session_id: request.session.id }
  end

  # def user_for_paper_trail
  #   logged_in? ? current_user.id : 0
  # end

  include ControllerHelper
  include ActionView::Helpers::OutputSafetyHelper
  helper Face::ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :journal_user, :check_notices

  rescue_from MayMay::Unauthorized, with: :not_authorized

  def not_authorized
    redirect_to main_app.root_path, alert: t("flash.not_authorized")
  end

  def journal_user
    logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
  end

  def check_notices
    return unless current_user
    return if request[:controller] =~ /\/admin\//

    #FIXME: each category should be processed separately in outstanding code
    notices = Core::Notice.where(sourceable: current_user, category: 1)
    return if notices.count==0

    list=[]
    notices.each do |note|
      list << note.message
      #next if flash[:'alert-badjobs'] && flash[:'alert-badjobs'].include?(text)
      #job=note.linkable
    end
    text = "#{notices.count==1 ? t('bad_job') : t('bad_jobs')} #{list.join '; '}"
    flash.now[:'alert-badjobs'] = raw text

  end
end
