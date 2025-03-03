class ApplicationController < ActionController::Base
  before_action do
    Octoface::OctoConfig.instances.values.each do |instance|
      next if %w[FakeMainApp Octoface].include? instance.mod.to_s

      app_helper = eval("#{instance.mod}::ApplicationHelper")
      ActionView::Base.include app_helper
    end
  end

  before_action :set_paper_trail_whodunnit
  before_action :show_blocked_email_alert

  def show_blocked_email_alert
    return unless current_user && current_user.block_emails

    flash_now_message('alert', t('users.unblock_emails.your_email_blocked',
                                 link: view_context.link_to(t('users.unblock_emails.link'),
                                                            main_app.unblock_emails_users_path,
                                                            method: :patch)).html_safe)
  end


  def authorize_admins
    #logger.error "ADMINS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    authorize!(:access, :admin)
  end

  def not_authenticated
    redirect_to main_app.root_path, alert: t("flash.not_logged_in")
  end

  def not_authorized
    # logger.error "-------------------------------------------"
    # logger.error caller(0).join("\n");
    redirect_to main_app.root_path, alert: t("flash.not_authorized")
  end

  rescue_from CanCan::AccessDenied, with: :not_authorized


  def info_for_paper_trail
    { session_id: request.session.id }
  end

  def octo_authorize!
    # logger.warn "AUTH: #{params[:controller]}"
    ret = authorize!(*::Octoface.action_and_subject_by_path(params[:controller]))
    # logger.warn "AUTH ret: #{ret}"
    ret
  end

  def admin_redirect_path
    if User.superadmins.include? current_user
      main_app.admin_users_path
    elsif User.experts.include? current_user
      sessions.admin_reports_path
    elsif User.support.include?(current_user) ||
          current_user.available_topics.any?
      support.admin_tickets_path
    elsif can?(:access, :admin)
      main_app.admin_users_path
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

  def journal_user
    logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
  end

  def check_notices
    return unless current_user
    #return if request[:controller] =~ /\/admin\//
    Core::Notice.show_notices(current_user, params, request).each do |data|
      flash_now_message(data[0], data[1])
    end
  end
end
