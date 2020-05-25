class ApplicationController < ActionController::Base

  before_action :set_paper_trail_whodunnit

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
  before_action :journal_user, :show_notices

  # rescue_from MayMay::Unauthorized, with: :not_authorized

  def journal_user
    logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
  end

  def check_notices
    return unless current_user
    return if request[:controller] =~ /\/admin\//

    #FIXME: each category should be processed separately in outstanding code
    notices = Core::Notice.where(sourceable: current_user, category: 1)
    return if notices.count==0

  end

  def conditional_show_notice note
    n = Time.current
    return if note.show_from && (note.show_from > n)
    return if note.show_till && (note.show_till < n)
    return if !note.active.nil? and note.active==false
    data = Core::Notice.handle note, current_user, params, request
    if data
      flash_now_message(data[0],data[1])
  def show_notices
    if current_user
      Core::Notice.show_notices(current_user, params, request).each do |data|
        flash_now_message(data[0],data[1])        
      end
    end
  end
end
