module Core
  module MergeDepartments
    # MERGE_TYPES = [:to_existing_department,:to_new_department,
    #                :to_organization].freeze
    extend ActiveSupport::Concern

    included do
      before_destroy do
        merge_associations({ organization_id: organization_id,
                             organization_department_id: id },
                           { organization_department_id: nil,
                             organization: organization })

      end
    end

    def create_organization!(attributes)
      organization = Organization.create!(attributes)
      if can_not_be_automerged?
        return DepartmentMerger.prepare_merge!(self, organization)
      end
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id },
                         { organization_department_id: nil,
                           organization: organization })
      destroy!
      organization
    end

    def create_organization(attributes)
      organization = nil
      transaction do
        organization = create_organization!(attributes)
      end
      organization
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class}  #{exception.message}"
    rescue ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    def merge_with_existing_department_without_check!(to_organization_id, to_department_id,avoid_merger = false)
      department = OrganizationDepartment.find(to_department_id)
      if to_organization_id != department.organization_id
        raise MergeError, 'stale_organization_id'
      end
      if !avoid_merger && can_not_be_automerged?
        return DepartmentMerger.prepare_merge!(self, department)
      end
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id },
                         { organization_department: department,
                           organization_id: department.organization_id })
      destroy!
    end

    def merge_with_existing_department!(to_organization_id, to_department_id)
      raise MergeError, 'same_object' if to_department_id == id
      merge_with_existing_department_without_check!(to_organization_id, to_department_id)
    end

    def merge_with_existing_department(to_organization_id, to_department_id)
      transaction do
        merge_with_existing_department!(to_organization_id, to_department_id)
      end
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class}  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    def merge_with_new_department_with_merger!(to_id)
      organization_id = self.organization_id
      update! organization_id: to_id, checked: true
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id },
                         { organization_id: to_id })

    end

    def merge_with_new_department!(to_id, name = self.name)
      organization_id = self.organization_id
      if can_not_be_automerged?
        update! name: name
        return DepartmentMerger.prepare_merge!(self, self, to_id)
      else
        update! organization_id: to_id, name: name, checked: true
      end
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id },
                         { organization_id: to_id })
    end

    def merge_with_new_department(to_id, name = self.name)
      transaction do
        merge_with_new_department!(to_id, name)
      end
      self
    rescue ActiveRecord::RecordInvalid => exception
      return self, "#{exception.record.class}  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return self, exception.message
    end

    def merge_with_organization!(to_id, avoid_merger = false, _destroy_departments = false)
      organization = Organization.find(to_id)
      if  !avoid_merger && can_not_be_automerged?
        return DepartmentMerger.prepare_merge!(self, organization)
      end
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id},
                         { organization_id: to_id,
                           organization_department_id: nil })

      destroy!
    end

    def merge_with_organization(to_id)
      transaction do
        merge_with_organization! to_id
      end
      true
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class} =>  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    def can_not_be_automerged?
      Member.can_not_be_automerged?(self) ||
        SuretyMember.can_not_be_automerged?(self) ||
        Project.can_not_be_automerged?(self)

    end

    def merge_associations(where_hash, update_hash)
      # member_hash = where_hash.slice(:organization_id)
      # Core::Member.where(member_hash)
      #             .where(users: users, organization: organization).each do |rec|
      #               rec.update!(update_hash)
      #             end
      Member.can_be_automerged(self).each do |rec|
        rec.update!(update_hash)
      end

      SuretyMember.can_be_automerged(self).each do |rec|
        rec.update!(update_hash)
      end

      Organization::MERGED_ASSOC.each do |model_class|
        model_class.where(where_hash)
                   .each do |rec|
                     rec.update!(update_hash)
        end
      end
    end

  end
end
