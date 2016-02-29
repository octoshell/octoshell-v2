# encoding: utf-8

# Отчет о проделанной работе по проекту.
module Sessions
  class Report < ActiveRecord::Base
    belongs_to :session

    belongs_to :project, class_name: "Core::Project", foreign_key: :project_id
    belongs_to :author, class_name: "::User", foreign_key: :author_id

    belongs_to :submit_denial_reason, class_name: "Sessions::ReportSubmitDenialReason", foreign_key: :submit_denial_reason_id

    belongs_to :expert, class_name: "::User"
    has_many :replies, class_name: "Sessions::ReportReply"

    mount_uploader :materials, ReportMaterialsUploader
    mount_uploader :export_materials, ReportExportMaterialsUploader, mount_on: :materials_file_name

    validates :materials, presence: true, if: :submitted?
    validates :materials, file_size: { maximum: 20.megabytes.to_i }, if: :submitted?
    validates :submit_denial_description, presence: true, if: -> { submit_denial_reason.present? }

    # after_create :notify_about_new_report

    state_machine :state, initial: :pending do
      state :pending
      state :can_not_be_submitted
      state :accepted
      state :submitted
      state :assessing
      state :assessed
      state :rejected
      state :exceeded

      event :accept do
        transition [:pending, :exceeded] => :accepted
      end

      event :decline_submitting do
        transition [:pending, :rejected, :exceeded] => :can_not_be_submitted
      end

      event :submit do
        transition [:exceeded, :accepted] => :submitted
      end

      event :pick do
        transition [:pending, :accepted, :submitted, :exceeded, :rejected] => :assessing
      end

      event :assess do
        transition [:assessed, :assessing] => :assessed
      end

      event :reject do
        transition [:can_not_be_submitted, :submitted, :assessing] => :rejected
      end

      event :edit do
        transition :assessed => :assessing
      end

      event :resubmit do
        transition :rejected => :assessing
      end

      event :postdate do
        transition [:pending, :accepted, :rejected] => :exceeded
      end

      inside_transition on: :assess, &:notify_about_assess
      inside_transition on: :reject, &:notify_about_reject
      inside_transition on: :postdate, &:block_project
    end

    def to_s
      %{Отчет по проекту "#{project.title}"}
    end

    def failed?
      [ illustration_points,
        statement_points,
        summary_points
      ].any? { |point| [1, 2].include? point }
    end

    def close_project!
      Sessions::MailerWorker.perform_async(:project_failed_session, id)
      project.block!
    end

    # def notify_about_new_report
    #   Sessions::MailerWorker.perform_async(:new_report, id)
    # end

    def notify_about_reject
      Sessions::MailerWorker.perform_async(:report_rejected, id)
    end

    def notify_about_pick
      Sessions::MailerWorker.perform_async(:report_picked, id)
    end

    def notify_about_assess
      Sessions::MailerWorker.perform_async(:report_assessed, id)
      if failed?
        project.block! unless project.blocked?
      end
    end

    def notify_about_resubmit
      Sessions::MailerWorker.perform_async(:report_resubmitted, id)
    end

    def block_project
      # Sessions::MailerWorker.perform_async(:postdated_report_on_project, id)
      project.block! unless project.blocked?
    end
  end
end
