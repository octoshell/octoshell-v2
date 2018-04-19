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

    def merge_to_existing_department!(to_organization_id, to_department_id)
      department = OrganizationDepartment.find(to_department_id)
      if to_organization_id != department.organization_id
        raise MergeError, 'stale_organization_id'
      end
      raise MergeError, 'same_object' if to_department_id == id
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id },
                         { organization_department: department,
                           organization_id: department.organization_id })
      destroy!
    end

    def merge_to_existing_department(to_organization_id, to_department_id)
      transaction do
        merge_to_existing_department!(to_organization_id, to_department_id)
      end
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class}  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    def merge_to_new_department!(to_id, name = self.name)
      organization_id = self.organization_id
      update! organization_id: to_id, name: name, checked: true
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id },
                         { organization_id: to_id })
    end

    def merge_to_new_department(to_id, name = self.name)
      transaction do
        merge_to_new_department!(to_id, name)
      end
      self
    rescue ActiveRecord::RecordInvalid => exception
      return self, "#{exception.record.class}  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return self, exception.message
    end

    def merge_to_organization!(to_id)
      Organization.find(to_id)
      merge_associations({ organization_id: organization_id,
                           organization_department_id: id},
                         { organization_id: to_id,
                           organization_department_id: nil })

      destroy!
    end

    def merge_to_organization(to_id)
      transaction do
        merge_to_organization! to_id
      end
      true
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class} =>  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    private

    def merge_associations(where_hash, update_hash)
      Organization::MERGED_ASSOC.each do |model_class|
        # puts model_class.to_s
        # puts where_hash
        # puts update_hash
        model_class.where(where_hash)
                   .each do |rec|
                    #  puts rec.inspect
                     rec.update!(update_hash)
        end
      end
    end
  end
end
