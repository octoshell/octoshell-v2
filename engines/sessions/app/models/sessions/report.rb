# encoding: utf-8
# == Schema Information
#
# Table name: sessions_reports
#
#  id                        :integer          not null, primary key
#  illustration_points       :integer
#  materials                 :string(255)
#  materials_content_type    :string(255)
#  materials_file_name       :string(255)
#  materials_file_size       :integer
#  materials_updated_at      :datetime
#  state                     :string(255)
#  statement_points          :integer
#  submit_denial_description :text
#  summary_points            :integer
#  created_at                :datetime
#  updated_at                :datetime
#  author_id                 :integer
#  expert_id                 :integer
#  project_id                :integer
#  session_id                :integer
#  submit_denial_reason_id   :integer
#
# Indexes
#
#  index_sessions_reports_on_author_id   (author_id)
#  index_sessions_reports_on_expert_id   (expert_id)
#  index_sessions_reports_on_project_id  (project_id)
#  index_sessions_reports_on_session_id  (session_id)
#

# Отчет о проделанной работе по проекту.
module Sessions
  class Report < ApplicationRecord

    POINT_RANGE = (0..5)
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

    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :pending, :initial => true
      state :can_not_be_submitted
      state :accepted
      state :submitted
      state :assessing
      state :assessed
      state :rejected
      state :exceeded

      event :accept do
        transitions :from => [:pending, :exceeded], :to => :accepted
      end

      event :decline_submitting do
        transitions :from => [:pending, :rejected, :exceeded], :to => :can_not_be_submitted
      end

      event :submit do
        transitions :from => [:exceeded, :accepted], :to => :submitted
      end

      event :pick do
        transitions :from => [:pending, :accepted, :submitted, :exceeded, :rejected], :to => :assessing
      end

      event :assess do
        transitions :from => [:assessed, :assessing], :to => :assessed, :after => :notify_about_assess
      end

      event :reject do
        transitions :from => [:can_not_be_submitted, :submitted, :assessing], :to => :rejected, :after => :notify_about_reject
      end

      event :edit do
        transitions :from => :assessed, :to => :assessing
      end

      event :resubmit do
        transitions :from => :rejected, :to => :assessing
      end

      event :postdate do
        transitions :from => [:pending, :accepted, :rejected], :to => :exceeded, :after => :block_project
      end
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
      project.block! unless project.blocked? or project.finished? or project.cancelled?
    end
  end
end
