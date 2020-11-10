# == Schema Information
#
# Table name: support_tickets
#
#  id                      :integer          not null, primary key
#  attachment              :string(255)
#  attachment_content_type :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  message                 :text
#  state                   :string(255)
#  subject                 :string(255)
#  url                     :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  cluster_id              :integer
#  project_id              :integer
#  reporter_id             :integer
#  responsible_id          :integer
#  surety_id               :integer
#  topic_id                :integer
#
# Indexes
#
#  index_support_tickets_on_cluster_id      (cluster_id)
#  index_support_tickets_on_project_id      (project_id)
#  index_support_tickets_on_reporter_id     (reporter_id)
#  index_support_tickets_on_responsible_id  (responsible_id)
#  index_support_tickets_on_state           (state)
#  index_support_tickets_on_topic_id        (topic_id)
#

module Support
  class Ticket < ApplicationRecord



    mount_uploader :attachment, AttachmentUploader
    mount_uploader :export_attachment, TicketAttachmentUploader, mount_on: :attachment_file_name

    belongs_to :reporter, class_name: Support.user_class.to_s, foreign_key: :reporter_id
    belongs_to :responsible, class_name: Support.user_class.to_s, foreign_key: :responsible_id
    belongs_to :project, class_name: "Core::Project"
    belongs_to :surety, class_name: "Core::Surety"
    belongs_to :cluster, class_name: "Core::Cluster"

    belongs_to :topic

    has_many :replies, inverse_of: :ticket, dependent: :destroy
    has_many :field_values, inverse_of: :ticket, dependent: :destroy, autosave: true # NOTE: fields are from topic

    has_and_belongs_to_many :tags,
                            join_table: :support_tickets_tags, dependent: :destroy

    has_and_belongs_to_many :subscribers,
                            class_name: "::User", # TODO: rails bug maybe?
                            join_table: :support_tickets_subscribers, dependent: :destroy

    validates :reporter, :reporter_id, :subject, :message, :topic, presence: true
    validates :attachment, file_size: {
                             maximum: 100.megabytes.to_i
                           }
    validate do
      template.present? && template == message && errors.add(:message, :equal_to_template)
    end

    # accepts_nested_attributes_for :field_values

    after_commit :add_reporter_to_subscribers, on: :create
    before_create :add_responsible
    after_commit :notify_support, on: :create

    scope :find_by_content, -> (q) do
      processed = q.mb_chars.split(' ').join('%')
      left_join(:replies).where("support_replies.message LIKE :q OR support_tickets.message LIKE :q",q: "%#{processed}%")
    end

    after_save do
      field_values.where(value: ['', nil]).destroy_all
    end

    def field_values_attributes(params)

    end


    def self.field_values_with_options(*args)
      rel = all
      rel = rel.joins(field_values: :topics_field)
      counter = 0
      strings = args.map do |a|
        first = "support_topics_fields.field_id = #{a.first}"
        arr = Array(a.second).select(&:present?)
        if arr.any?
          second = Array(a.second).select(&:present?).map do |elem|
            counter += 1
            "support_field_values.value = '#{elem}'"
          end.join(' OR ')
          "#{first} AND (#{second})"
        else
          counter += 1
          first
        end
      end
      rel.where(strings.join(' OR ')).joins(:field_values).group(:id)
         .having('count(support_field_values.id) = ?', counter)
    end

    def self.contains_all_fields(*_ids)
      all
    end



    def self.ransackable_scopes(_auth_object = nil)
      %i[find_by_content field_values_with_options contains_all_fields]
    end

    def self.ransackable_scopes_skip_sanitize_args
      ransackable_scopes
    end

    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :pending, :initial => true
      state :answered_by_support
      state :answered_by_reporter
      state :resolved
      state :closed

      event :attach_support_reply do
        transitions :from => [:pending, :resolved, :answered_by_support,
                              :answered_by_reporter],
                    :to => :answered_by_support
      end

      event :attach_reporter_reply do
        transitions :from => [:pending, :resolved,
                              :answered_by_support,
                              :answered_by_reporter],
                    :to => :answered_by_reporter
      end

      event :resolve do
        transitions :from => [:pending,
                              :answered_by_reporter,
                              :answered_by_support],
                    :to => :resolved
      end

      event :reopen do
        transitions :from => [:closed, :resolved], :to => :pending
      end

      event :close do
        transitions :from => [:pending, :resolved,
                              :answered_by_support,
                              :answered_by_reporter],
                    :to => :closed
      end

      after_all_transitions :log_status_change
    end

    def log_status_change
      #puts "======> changing from #{aasm(:state).from_state} to #{aasm(:state).to_state} (event: #{aasm(:state).current_event})"
    end

    #include ::AASM_Additions
    # def state_name
    #   state.to_s
    # end

    # def human_state_name st=nil
    #   st.nil? ? state.to_s : st.to_s
    # end

    # def self.human_state_event_name s
    #   s.to_s
    # end

    # def self.human_state_names
    #   aasm(:state).states
    # end

    def select_field_values
      field_values.select do |f_v|
        f_v.value.present? && (f_v.field.model_collection.present? ||
          f_v.field.field_options.any?)
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

    def topics(for_user = false)
      if topic
        (for_user ? topic.visible_subtopics : topic.subtopics)
      else
        for_user ? Topic.visible_root : Topic.root
      end.order_by_name
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
                   project.members.where(user_id: reporter.id)
                 else
                   reporter.accounts
                 end

      accounts.map(&:login).join(", ")
    end

    def has_blank_fields?
      ![url, attachment, project, cluster].all?(&:present?) ||
        (!field_values.blank? && field_values.any?{ |fv| fv.value.blank? })
    end

    def possible_responsibles
      all_user_topics = topic.parents_with_self.map(&:user_topics).flatten
      hash = all_user_topics.group_by(&:user)
      (User.support.to_a - all_user_topics.map(&:user)).each do |user|
        hash[user] = []
      end
      hash
    end

    def template
      topic.parents_with_self.detect do |topic|
        topic.template.present?
      end&.template
    end

    def build_field_values
      topics_fields_to_fill.each do |topics_field|
        field_values.build do |value|
          value.topics_field = topics_field
        end
      end
    end

    def topics_fields_to_fill
      (topic.parents_with_self.map { |t| t.topics_fields.to_a } +
        Support::TopicsField.where(topic_id: nil).joins(:field_values)
                            .where(support_field_values: { ticket_id: id }).to_a)
      .flatten.uniq(&:field_id)
    end

    def old_fields(topic_id)
      Support::Topic.all_fields(topic_id) - topics_fields_to_fill
    end

    def new_fields(topic_id)
      topics_fields_to_fill - Support::Topic.all_fields(topic_id)
    end

    def destroy_stale_fields!
      field_values.reject do |f_v|
        topics_fields_to_fill.include?(f_v.topics_field)
      end.each(&:destroy)
    end

    private

    def add_responsible
      responsible = topic.parents_with_self.detect do |topic|
        topic.user_topics.where(required: true).first
      end&.user_topics&.where(required: true)&.first
      return unless responsible
      self.responsible = responsible.user
      subscribers << responsible.user unless subscribers.include? responsible
    end

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
