module Core
  class DepartmentMerger < ActiveRecord::Base
    belongs_to :source_department,
               class_name: 'Core::OrganizationDepartment',
               foreign_key: :source_department_id
    belongs_to :to_organization,
               class_name: 'Core::Organization',
               foreign_key: :to_organization_id
    belongs_to :to_department,
               class_name: 'Core::OrganizationDepartment',
               foreign_key: :to_department_id

    def self.prepare_merge!(source, to, to_org_id = nil)
      if to.instance_of?(OrganizationDepartment)
        if to_org_id
          find_or_create_by!(source_department: source, to_department: to,
                             to_organization_id: to_org_id)
        else
          find_or_create_by!(source_department: source, to_department: to)
        end
      elsif to.instance_of?(Organization)
        find_or_create_by!(source_department: source, to_organization: to)
      else
        raise StandardError, 'Invalid to arg'
      end
    end
    def complete_merge!(project_ids, surety_members_ids, core_members)
      transaction do
        Project.where(id: project_ids,organization_id: source_department.organization_id).each do |project|
          project.update!(organization_department_id: source_department.id)
        end
        SuretyMember.where(id: surety_members_ids + core_members.map(&:second).compact, organization_id: source_department.organization_id).each do |member|
          member.update!(organization_department_id: source_department.id)
        end
        Member.where(id: core_members.map(&:first), organization_id: source_department.organization_id).each do |member|
          member.update!(organization_department_id: source_department.id)
        end
        merge!
        destroy!
      end
    rescue StandardError => exception
      return "#{exception.class}  #{exception.message}"
    end

    def merge!
      if to.instance_of?(Organization)
        source_department.merge_with_organization!(to_organization_id, true)
      elsif to.instance_of?(OrganizationDepartment)
        if to_organization_id
          source_department.merge_with_new_department_with_merger!(to_organization_id)
        else
          source_department.merge_with_existing_department_without_check!(to.organization_id, to.id, true)
        end
      else
        raise StandardError, 'Invalid to arg'
      end
    end

    def to
      to_department ? to_department : to_organization
    end
  end
end
