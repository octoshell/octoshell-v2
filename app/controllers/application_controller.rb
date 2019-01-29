class ApplicationController < ActionController::Base

  include ControllerHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :journal_user, :check_notices

  def journal_user
    logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
  end

  def check_notices
    return unless current_user
    return if request[:controller] =~ /\/admin\//
    Core::Notice.where(sourceable: current_user, category: 1).each do |note|
      text = "#{note.message} - #{note.linkable.drms_job_id}"
      next if flash[:alert] && flash[:alert].include?(text)
      job=note.linkable
      flash_message :alert, text
    end
  end
end
