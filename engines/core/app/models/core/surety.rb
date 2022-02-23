# encoding: utf-8
# == Schema Information
#
# Table name: core_sureties
#
#  id             :integer          not null, primary key
#  boss_full_name :string(255)
#  boss_position  :string(255)
#  comment        :string(255)
#  document       :string(255)
#  reason         :text
#  state          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  author_id      :integer
#  changed_by_id  :integer
#  project_id     :integer
#
# Indexes
#
#  index_core_sureties_on_author_id      (author_id)
#  index_core_sureties_on_changed_by_id  (changed_by_id)
#  index_core_sureties_on_project_id     (project_id)
#

module Core
  class Surety < ApplicationRecord
    include Exportable

    delegate :organization, :organization_department, to: :project

    belongs_to :author, class_name: Core.user_class.to_s, foreign_key: :author_id, inverse_of: :authored_sureties
    belongs_to :project, inverse_of: :sureties
    belongs_to :changed_by, class_name: '::User'
    has_many :surety_members, inverse_of: :surety, dependent: :destroy
    has_many :members, class_name: Core.user_class.to_s, through: :surety_members, source: :user

    has_many :scans, class_name: "Core::SuretyScan", dependent: :destroy

    validates :project, presence: true
    validates :surety_members, length: { minimum: 1, message: I18n.t("errors.choose_at_least") }

    validates :scans, length: { minimum: 1, message: I18n.t("errors.choose_at_least") },
              :if => -> {aasm(:state).current_state == :confirmed}

    accepts_nested_attributes_for :scans, allow_destroy: true, :reject_if => ->(attr){ attr["image"].blank?  }

    mount_uploader :document, SuretyDocumentUploader

    after_create :save_rft_document

    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :generated, :initial => true
      state :confirmed
      state :rejected
      state :active
      state :closed

      event :confirm, after: :prepare_for_approvement do
        transitions :from => [:generated, :rejected], :to => :confirmed
      end

      event :reject, after: :notify_onwer_about_rejection do
        transitions :from => :confirmed, :to => :rejected
      end

      event :activate, after: :activate_project_accounts do
        transitions :from => [:confirmed, :generated], :to => :active
      end

      event :close, after: :substract_project_accounts do
        transitions :from => [:generated, :confirmed, :rejected, :active], :to => :closed
      end

      # inside_transition :on => :confirm, &:prepare_for_approvement
      # inside_transition :on => :reject, &:notify_onwer_about_rejection
      # inside_transition :on => :activate, &:activate_project_accounts
      # inside_transition :on => :close, &:substract_project_accounts
    end

    def prepare_for_approvement
      self.save_rft_document
      ::Core::MailerWorker.perform_async(:surety_confirmed, id)
    end

    def activate_project_accounts
      ::Core::MailerWorker.perform_async(:surety_accepted, id)
      ::Core::Member.where(project_id: project_id, user_id: member_ids).where(:project_access_state=>[:unsured, :suspended]).map(&:activate!)
      project.synchronize! if project.active?
    end

    def notify_onwer_about_rejection
      ::Core::MailerWorker.perform_async(:surety_rejected, id)
    end

    def substract_project_accounts
      ::Core::Member.where(project_id: project_id, user_id: member_ids).map(&:substract_from_surety!)
    end

    def name
      "#{Surety.model_name.human} #{I18n.t("util.number")}#{id}"
    end

    # def human_state_name
    #   state.to_s
    # end

    # def self.human_state_event_name e
    #   e.to_s
    # end

    # def state_name
    #   state.to_s
    # end

    def to_s
      name
    end

    def save_rft_document
      tempfile = Tempfile.new(["surety_#{id}", ".rtf"])
      tempfile.write generate_rtf
      tempfile.close
      update(document: tempfile)
      tempfile.delete
    end

    def full_organization_name
      if organization.present?
        employment = author.employments.find_by_organization_id(organization.id)
        if organization_department.present?
          "#{organization.name} (#{organization_department.name})"
        elsif employment.present? && (fak = employment.positions.find{|p| p.name_ru == "Факультет"}).present?
          "#{organization.name} (#{fak.name} #{fak.value})"
        else
          organization.name
        end
      else
        "Не указана!"
      end
    end
  end
end
