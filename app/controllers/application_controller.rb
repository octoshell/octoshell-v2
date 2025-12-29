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
    # logger.error "ADMINS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    authorize!(:access, :admin)
  end

  def not_authenticated
    redirect_to main_app.root_path, alert: t('flash.not_logged_in')
  end

  def not_authorized
    # logger.error "-------------------------------------------"
    # logger.error caller(0).join("\n");
    redirect_to main_app.root_path, alert: t('flash.not_authorized')
  end

  rescue_from CanCan::AccessDenied, with: :not_authorized

  def info_for_paper_trail
    { session_id: request.session.id }
  end

  def octo_authorize!
    # logger.warn "AUTH: #{params[:controller]}"
    authorize!(*::Octoface.action_and_subject_by_path(params[:controller]))
    # logger.warn "AUTH ret: #{ret}"
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
    %i[id name category
       name_type options_category_id value_type
       category_value_id name_ru name_en
       value_ru value_en _destroy admin]
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

    # return if request[:controller] =~ /\/admin\//
    Core::Notice.show_notices(current_user, params, request).each do |data|
      flash_now_message(data[0], data[1])
    end
  end
  helper_method :menu_items
  helper_method :user_submenu_items
  helper_method :admin_submenu_items

  def menu_items
    menu = Face::MyMenu.new
    # menu.items.clear
    if Octoface::OctoConfig.find_by_role(:core) && logged_in?
      menu.add_item_without_key(t('main_menu.working_area'), core.root_path, /^((?!admin|wiki).)*$/s)
    end
    menu.add_item_without_key(t('main_menu.admin_area'), admin_redirect_path, /admin/) if can?(:access, :admin)
    # menu.add_item_without_key(wiki_item)
    if Octoface::OctoConfig.find_by_role(:wiki)
      menu.add_item_without_key(t('main_menu.wikiplus'), wikiplus.root_path, /wikiplus/)
    end

    # menu.add_item(working_area_item) if logged_in?
    # menu.add_item(admin_area_item) if can?(:access, :admin)
    # menu.add_item(wiki_item)
    # menu.add_item(wikiplus_item)
    menu.items(self)
  end

  def wiki_item
    wikiplus_item
    # Face::MenuItem.new({
    #   name: t("main_menu.wiki"),
    #   url: wiki.root_path,
    #   regexp: /wiki/
    # })
  end

  def wikiplus_item
    Face::MenuItem.new({
                         name: t('main_menu.wikiplus'),
                         url: wikiplus.root_path,
                         regexp: /wikiplus/
                       })
  end

  def working_area_item
    Face::MenuItem.new({
                         name: t('main_menu.working_area'),
                         url: core.root_path,
                         regexp: /^((?!admin|wiki).)*$/s
                       })
  end

  def admin_area_item
    Face::MenuItem.new({
                         name: t('main_menu.admin_area'),
                         url: admin_redirect_path,
                         regexp: /admin/
                       })
  end

  def user_submenu_items
    Face::MyMenu.user_submenu(self)
  end

  def admin_submenu_items
    Face::MyMenu.admin_submenu(self)
  end
end
