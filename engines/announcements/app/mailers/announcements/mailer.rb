module Announcements
  class Mailer < ActionMailer::Base
    def announcement(recipient_id)
      recipient = AnnouncementRecipient.find(recipient_id)
      @user = recipient.user
      @announcement = recipient.announcement
      if @announcement.attachment.present?
        attachments[@announcement.attachment.file.filename] = File.read(@announcement.attachment.current_path)
      end
      mail to: @user.email, subject: @announcement.title
    end

    private

    def markdown(text)
      Kramdown::Document.new(text, filter_html: true).to_html.html_safe
    end
    helper_method :markdown
  end
end
