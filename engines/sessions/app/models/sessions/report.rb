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


    prepend(ReportProject) if Sessions.link?(:project)


    POINT_RANGE = (0..5)
    belongs_to :session
    # belongs_to :project, class_name: "Core::Project", foreign_key: :project_id
    belongs_to :author, class_name: "::User", foreign_key: :author_id
    belongs_to :submit_denial_reason, class_name: "Sessions::ReportSubmitDenialReason", foreign_key: :submit_denial_reason_id
    belongs_to :expert, class_name: "::User"
    has_many :replies, class_name: "Sessions::ReportReply"
    has_many :report_materials, inverse_of: :report

    mount_uploader :materials, ReportMaterialsUploader
    mount_uploader :export_materials, ReportExportMaterialsUploader, mount_on: :materials_file_name

    # accepts_nested_attributes_for :report_materials

    # validates :old_materials, presence: true, if: :submitted?
    # validates :old_materials, file_size: { maximum: 20.megabytes.to_i }, if: :submitted?
    validates :submit_denial_description, presence: true, if: -> { submit_denial_reason.present? }
    validates_associated :report_materials

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

      event :pick, after_commit: :notify_about_pick do
        transitions :from => [:pending, :accepted, :submitted, :exceeded, :rejected], :to => :assessing
      end

      event :assess, after_commit: :notify_about_assess do
        transitions :from => [:assessed, :assessing], :to => :assessed
      end

      event :reject,  after_commit: :notify_about_reject do
        transitions :from => [:can_not_be_submitted, :submitted, :assessing], :to => :rejected
      end

      event :edit do
        transitions :from => :assessed, :to => :assessing
      end

      event :resubmit, after_commit: :notify_about_resubmit do
        transitions :from => :rejected, :to => :assessing
      end

      event :postdate, after_commit: :postdate_callback do
        transitions :from => [:pending, :accepted, :rejected], :to => :exceeded
      end
    end

    %w[illustration_points statement_points summary_points].each do |type|
      @ransackable_scopes ||= []
      name = "#{type}_in_with_null"
      @ransackable_scopes << name
      define_singleton_method(name) do |*points|
        where("#{type}": points.select(&:present?).map { |a| a == 'not_evaluated' ? nil : a })
      end
    end

    def self.five_exists()
      str =%w[illustration_points statement_points summary_points].map do |type|
        "(sessions_reports.#{type} = 5)"
      end.join(' OR ')
      where(str)
    end

    def self.ransackable_scopes(_auth_object = nil)
      (@ransackable_scopes || []) + ['five_exists']
    end



    def report_material=(hash)
      report_materials.new hash
    end

    # def materials
    #   nil
    #   # ReportMaterial.where(report_id: id).last.&materials
    # end

    def to_s
      %{Отчет по проекту "#{project.title}"}
    end

    def failed?
      [ illustration_points,
        statement_points,
        summary_points
      ].any? { |point| [1, 2].include? point }
    end

    # def close_project!
    #   Sessions::MailerWorker.perform_async(:project_failed_session, id)
    #   project.block!
    # end

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
    end

    def notify_about_resubmit
      Sessions::MailerWorker.perform_async(:report_resubmitted, id)
    end

    def postdate_callback; end

    # def block_project
    #   # Sessions::MailerWorker.perform_async(:postdated_report_on_project, id)
    #   project.block! unless project.blocked? or project.finished? or project.cancelled?
    # end
  end
end
