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

    def hard_markdown(text)
      Commonmarker.to_html(text,
                           options: {
                             render: { unsafe: true }
                           }).html_safe

      # ::Commonmarker.to_html(text, :DEFAULT, %i[table autolink]).html_safe
    end
    helper_method :hard_markdown
  end
end
