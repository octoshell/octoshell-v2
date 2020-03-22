class ApplicationController < ActionController::Base

  before_action :set_paper_trail_whodunnit

  def authorize_admins
    authorize!(:access, :admin)
  end

  def not_authenticated
    redirect_to main_app.root_path, alert: t("flash.not_logged_in")
  end

  def not_authorized
    redirect_to main_app.root_path, alert: t("flash.not_authorized")
  end

  rescue_from CanCan::AccessDenied, with: :not_authorized


  def info_for_paper_trail
    { session_id: request.session.id }
  end

  def octo_authorize!
    authorize!(*::Octoface.action_and_subject_by_path(params[:controller]))
  end

  def admin_redirect_path
    if User.superadmins.include? current_user
      main_app.admin_users_path
    elsif User.experts.include? current_user
      sessions.admin_reports_path
    elsif User.support.include?(current_user) ||
          current_user.available_topics.any?
      support.admin_tickets_path
    else
      core.projects_path
    end
  end


  def options_attributes
    [:id, :name, :category,
     :name_type, :options_category_id, :value_type,
     :category_value_id, :name_ru, :name_en,
     :value_ru, :value_en, :_destroy, :admin]
  end

  include ControllerHelper
  include ActionView::Helpers::OutputSafetyHelper
  helper Face::ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :journal_user, :check_notices

  # rescue_from MayMay::Unauthorized, with: :not_authorized

  def journal_user
    logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
  end

  def check_notices
    return unless current_user
    return if request[:controller] =~ /\/admin\//
    return unless Octoface::OctoConfig.find_by_role(:core)
    
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
