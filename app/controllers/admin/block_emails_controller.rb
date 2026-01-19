require 'ostruct'
class Admin::BlockEmailsController < Admin::ApplicationController
  # before_action :setup_default_filter, only: :index
  before_action :octo_authorize!
  def select_box
    @form = BlockEmails::Form.new(date_gte: Date.current - 30.days)
  end

  def fetch_emails
    @form = BlockEmails::Form.new(block_emails_form_attributes)
    emails_messages = @form.try_to_submit
    unless emails_messages
      render :select_box
      return
    end
    @users = User.where('lower(email) IN (?)', emails_messages.map(&:first)
                                                              .compact
                                                               .map(&:downcase))
    @emails = emails_messages.group_by(&:first).map do |k, v|
      OpenStruct.new(
        email: k,
        user: @users.detect { |u| u.email.downcase == k&.downcase },
        messages: v.map(&:second) # .join("<br><br> #{t('.delim')} <br><br>")
        # .html_safe
      )
    end
  end

  def block_emails
    User.where(id: params[:ids] || []).each do |u|
      u.update!(block_emails: true)
    end
    redirect_to admin_users_path, flash: { info: t('.success') }
  end

  private

  def block_emails_form_attributes
    params.require(:block_emails_form).permit(:name, :date_gte)
  end
end
