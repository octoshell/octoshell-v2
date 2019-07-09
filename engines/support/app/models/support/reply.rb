# == Schema Information
#
# Table name: support_replies
#
#  id                      :integer          not null, primary key
#  attachment              :string(255)
#  attachment_content_type :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  message                 :text
#  created_at              :datetime
#  updated_at              :datetime
#  author_id               :integer
#  ticket_id               :integer
#
# Indexes
#
#  index_support_replies_on_author_id  (author_id)
#  index_support_replies_on_ticket_id  (ticket_id)
#

module Support
  class Reply < ActiveRecord::Base

    has_paper_trail

    mount_uploader :attachment, AttachmentUploader
    #mount_uploader :export_attachment, ReplyAttachmentUploader, mount_on: :attachment_file_name

    belongs_to :author, class_name: Support.user_class, foreign_key: :author_id
    belongs_to :ticket

    validates :author, :ticket, :message, presence: true
    validates :attachment, file_size: { maximum: 100.megabytes.to_i }
    #validates_presence_of  :attachment

    def create_or_update
      if new_record?
        attach_answered_by_flag
        notify_subscribers
        ticket.subscribers << author unless ticket.subscribers.include? author
      end

      super
    end

    def to_s
      self.class.model_name.human
    end

    def attach_answered_by_flag
      if author_id == ticket.reporter_id
        ticket.attach_reporter_reply!
      else
        ticket.update(responsible_id: author_id) if (ticket.pending? || ticket.answered_by_reporter?) && !ticket.responsible
        ticket.attach_support_reply!
      end
    end

    def notify_subscribers
      (ticket.subscribers - [author]).each do |user|
        Support::MailerWorker.perform_async(:new_ticket_reply, [ticket_id, user.id])
      end
    end
  end
end
