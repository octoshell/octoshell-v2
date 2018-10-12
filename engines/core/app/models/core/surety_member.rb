module Core
  class SuretyMember < ActiveRecord::Base
    belongs_to :user, class_name: Core.user_class
    belongs_to :surety
    belongs_to :organization
    belongs_to :organization_department

    delegate :email, :full_name, to: :user

    def self.department_members(department)
      where(organization_id: department.organization_id)
        .where("core_surety_members.organization_department_id is NULL
          OR core_surety_members.organization_department_id = #{department.id}")
        .joins("INNER JOIN core_employments AS u_e ON core_surety_members.user_id = u_e.user_id AND
          u_e.organization_department_id = #{department.id}")
        .joins("LEFT JOIN core_employments As e ON
          e.organization_id = #{department.organization_id} AND
          core_surety_members.user_id = e.user_id")
        .group('core_surety_members.id')
    end

    def self.can_be_automerged(department)
      department_members(department).having("COUNT( DISTINCT COALESCE(e.organization_department_id,-1)) = 1")
    end

    def self.can_not_be_automerged(department)
      department_members(department).having("COUNT( DISTINCT COALESCE(e.organization_department_id,-1)) > 1")
    end

    def self.can_not_be_automerged?(department)
      can_not_be_automerged(department).exists?
    end
  end
end
