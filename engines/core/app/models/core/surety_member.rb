# == Schema Information
#
# Table name: core_surety_members
#
#  id                         :integer          not null, primary key
#  organization_department_id :integer
#  organization_id            :integer
#  surety_id                  :integer
#  user_id                    :integer
#
# Indexes
#
#  index_core_surety_members_on_organization_id  (organization_id)
#  index_core_surety_members_on_surety_id        (surety_id)
#  index_core_surety_members_on_user_id          (user_id)
#

module Core
  class SuretyMember < ApplicationRecord
    belongs_to :user, class_name: Core.user_class.to_s
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

    def self.full_names_and_posts
      includes(user: [:profile, { employments: :positions }]).to_a.map do |m|
        employment = m.user.employments.detect do |e|
          e.organization_id == m.organization_id &&
            e.organization_department_id == m.organization_department_id
        end || m.user.employments.detect do |e|
          e.organization_id == m.organization_id
        end
        "#{m.full_name}, #{employment&.post_in_organization || I18n.t('core.sureties.fill_post')}"
      end
    end
  end
end
