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
    Core::Notice.where(sourceable: current_user, category: 1).each do |note|
      job=note.linkable
      flash["job-#{job.id}"] = note.message
    end
  end
end
