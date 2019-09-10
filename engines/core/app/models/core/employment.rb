# encoding: utf-8
# == Schema Information
#
# Table name: core_employments
#
#  id                         :integer          not null, primary key
#  primary                    :boolean
#  state                      :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  organization_department_id :integer
#  organization_id            :integer
#  user_id                    :integer
#
# Indexes
#
#  index_core_employments_on_organization_department_id  (organization_department_id)
#

module Core
  class Employment < ActiveRecord::Base

    belongs_to :user, class_name: Core.user_class, foreign_key: :user_id, inverse_of: :employments
    belongs_to :organization
    belongs_to :organization_department

    has_many :positions, class_name: "Core::EmploymentPosition", inverse_of: :employment,dependent: :destroy
    accepts_nested_attributes_for :positions, reject_if: proc { |a| (a['value'].blank? && a['field_id'].blank?) && a['id'].blank? }

    before_save :check_primacy

    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :active, :initial => true
      state :closed

      event :deactivate do
        transitions :from => :active, :to => :closed
      end
    end

    def self.joins_active_users
      joins("INNER JOIN users AS u ON
            u.id = core_employments.user_id AND u.activation_state = 'active'")
    end
    def full_name
      if organization_department.present?
        "#{organization.short_name}, #{organization_department.name}"
      else
        if organization.present?
          organization.name
        else
          I18n.t("errors.user.employment.organization_was_incorrect_and_deleted.html").html_safe
        end
      end
    end

    def organization_department_name
      organization_department.try(:name)
    end

    def organization_department_name=(name)
      self.organization_department = organization.departments.where(name: name.mb_chars).first_or_create! if name.present? && organization.present?
    end

    def build_default_positions
      names = positions.map(&:name_ru)
      EmploymentPositionName.all.each do |position_name|
        if names.exclude? position_name.name_ru
          positions.build(employment_position_name: position_name)
        end
      end
    end

    def post_in_organization
      positions.find do |p|
        p.employment_position_name.name_ru == "Должность по РФФИ"
      end.try(:selected_value)
    end

    def position_info
      positions.select do |p|
        ["Должность по РФФИ", "Должность"].exclude?(p.employment_position_name.name_ru)
      end
    end

    private

    def check_primacy
      if user.employments.where(primary: true).any? && primary_changed? &&
         primary_was == false
        user.employments.update_all(primary: false)
      end
    end
  end
end
