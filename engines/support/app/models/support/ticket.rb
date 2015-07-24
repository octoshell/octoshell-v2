module Support
  class Ticket < ActiveRecord::Base
    mount_uploader :attachment, AttachmentUploader
    mount_uploader :export_attachment, TicketAttachmentUploader, mount_on: :attachment_file_name

    belongs_to :reporter, class_name: Support.user_class, foreign_key: :reporter_id
    belongs_to :responsible, class_name: Support.user_class, foreign_key: :responsible_id
    belongs_to :project, class_name: "Core::Project"
    belongs_to :surety, class_name: "Core::Surety"
    belongs_to :cluster, class_name: "Core::Cluster"

    belongs_to :topic

    has_many :replies, inverse_of: :ticket, dependent: :destroy
    has_many :field_values, inverse_of: :ticket, dependent: :destroy # NOTE: fields are from topic

    has_and_belongs_to_many :tags,
                            join_table: :support_tickets_tags, dependent: :destroy

    has_and_belongs_to_many :subscribers,
                            class_name: "::User", # TODO: rails bug maybe?
                            join_table: :support_tickets_subscribers, dependent: :destroy

    validates :reporter, :subject, :message, :topic, presence: true
    validates :attachment, file_size: {
                             maximum: 100.megabytes.to_i
                           }

    accepts_nested_attributes_for :field_values

    after_create :add_reporter_to_subscribers
    after_create :notify_support

    state_machine :state, initial: :pending do
      state :pending
      state :answered_by_support
      state :answered_by_reporter
      state :resolved
      state :closed

      event :attach_support_reply do
        transition [:pending, :resolved,
                    :answered_by_support,
                    :answered_by_reporter] => :answered_by_support
      end

      event :attach_reporter_reply do
        transition [:pending, :resolved,
                    :answered_by_support,
                    :answered_by_reporter] => :answered_by_reporter
      end

      event :resolve do
        transition [:pending,
                    :answered_by_reporter,
                    :answered_by_support] => :resolved
      end

      event :reopen do
        transition :closed => :pending
      end

      event :close do
        transition [:pending, :resolved,
                    :answered_by_support,
                    :answered_by_reporter] => :closed
      end
    end

    def accept(user)
      replies.create! do |reply|
        reply.author = user
        reply.message = I18n.t("actions.ticket_accepted")
      end
    end

    def actual?
      not closed?
    end

    def topics
      if topic
        topic.subtopics
      else
        Topic.root
      end
    end

    def show_questions?
      !topic || topic.subtopics.any?
    end

    def show_form?
      topic && !topic.subtopics.any?
    end

    def to_s
      subject
    end

    def available_subscribers
      subscribers = []
      subscribers << reporter
      User.support.each do |user|
        subscribers << user
      end
      subscribers
    end

    def find_next_ticket_from(tickets_list)
      tickets_list = tickets_list || ""
      tickets = tickets_list.split(',')
      ticket_index = tickets.find_index(self.id.to_s)
      if ticket_index && (next_ticket_id = tickets[ticket_index.next])
        Ticket.find(next_ticket_id)
      end
    end

    def reporter_logins
      accounts = if project
                   project.members
                 else
                   reporter.accounts
                 end

      accounts.map(&:login).join(", ")
    end

    def has_blank_fields?
      ![url, attachment, project, cluster].all?(&:present?) ||
        (!field_values.blank? && field_values.any?{ |fv| fv.value.blank? })
    end

    private

    def add_reporter_to_subscribers
      subscribers << reporter unless subscribers.include? reporter
    end

    def notify_support
      # TODO notify user if ticket created by admin!
      Support::MailerWorker.perform_async(:new_ticket, id)
      true
    end
  end
end
