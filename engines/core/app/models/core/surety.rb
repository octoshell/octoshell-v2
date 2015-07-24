# encoding: utf-8

module Core
  class Surety < ActiveRecord::Base
    include Exportable

    delegate :organization, :organization_department, to: :project

    belongs_to :author, class_name: Core.user_class, foreign_key: :author_id, inverse_of: :authored_sureties
    belongs_to :project, inverse_of: :sureties

    has_many :surety_members, inverse_of: :surety, dependent: :destroy
    has_many :members, class_name: Core.user_class, through: :surety_members, source: :user

    has_many :scans, class_name: "Core::SuretyScan", dependent: :destroy

    validates :project, presence: true
    validates :surety_members, length: { minimum: 1, message: I18n.t(".errors.choose_at_least") }

    accepts_nested_attributes_for :scans, allow_destroy: true, :reject_if => ->(attr){ attr["image"].blank?  }

    mount_uploader :document, SuretyDocumentUploader

    after_create :save_rft_document

    state_machine initial: :generated do
      state :generated
      state :confirmed do
        validates :scans, length: { minimum: 1, message: I18n.t(".errors.choose_at_least") }
      end
      state :rejected
      state :active
      state :closed

      event :confirm do
        transition [:generated, :rejected] => :confirmed
      end

      event :reject do
        transition :confirmed => :rejected
      end

      event :activate do
        transition [:confirmed, :generated] => :active
      end

      event :close do
        transition [:generated, :confirmed, :rejected, :active] => :closed
      end

      inside_transition :on => :confirm, &:prepare_for_approvement
      inside_transition :on => :reject, &:notify_onwer_about_rejection
      inside_transition :on => :activate, &:activate_project_accounts
      inside_transition :on => :close, &:substract_project_accounts
    end

    def prepare_for_approvement
      self.save_rft_document
      Core::MailerWorker.perform_async(:surety_confirmed, id)
    end

    def activate_project_accounts
      Core::MailerWorker.perform_async(:surety_accepted, id)
      Core::Member.where(project_id: project_id, user_id: member_ids).with_project_access_state([:unsured, :suspended]).map(&:activate!)
      project.synchronize! if project.active?
    end

    def notify_onwer_about_rejection
      Core::MailerWorker.perform_async(:surety_rejected, id)
    end

    def substract_project_accounts
      Core::Member.where(project_id: project_id, user_id: member_ids).map(&:substract_from_surety!)
    end

    def name
      "#{Surety.model_name.human} #{I18n.t("util.number")}#{id}"
    end

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
        elsif employment.present? && (fak = employment.positions.find{|p| p.name == "Факультет"}).present?
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
