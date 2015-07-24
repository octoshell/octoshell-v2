# encoding: utf-8
module Core
  class Employment < ActiveRecord::Base
    belongs_to :user, class_name: Core.user_class, foreign_key: :user_id, inverse_of: :employments
    belongs_to :organization
    belongs_to :organization_department

    has_many :positions, class_name: "Core::EmploymentPosition", inverse_of: :employment
    accepts_nested_attributes_for :positions, reject_if: proc { |a| a['value'].blank? }

    before_save :check_primacy

    state_machine :state, initial: :active do
      state :active
      state :closed

      event :deactivate do
        transition :active => :closed
      end
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

    # TODO: переделать build_default_positions & find_existed_position
    # пока 1 в 1 из старого octoshell.
    def build_default_positions
      @existed_positions = positions.to_a.dup

      transaction do
        self.positions = []
        EmploymentPositionName.all.each do |position_name|
          positions.build do |position|
            position.name = position_name.name
            position.value = find_existed_position(position_name).try(:value)
            position.try_save
          end
        end
      end
    end

    def find_existed_position(position_name)
      @existed_positions.find do |p|
        p.name == position_name.name
      end
    end

    def post_in_organization
      positions.find{ |p| p.name == "Должность по РФФИ" }.try(:value)
    end

    def position_info
      (positions.select{ |p| not ["Должность по РФФИ", "Должность"].include?(p.name) })
    end

    private

    def check_primacy
      if user.employments.where(primary: true).any?
        if primary_changed? && (primary_was == false)
          user.employments.update_all(primary: false)
        end
      else
        primary = true if new_record?
      end
    end
  end
end
