module Core
  module MergeOrganzations
    # MERGE_TYPES = [:to_existing_department,:to_new_department,
    #                :to_organization].freeze
    extend ActiveSupport::Concern

    module ClassMethods
      def create_or_find_unknown
        country = Country.find_or_create_by!(title_en: 'Unknown')
        city = City.find_or_create_by!(title_en: 'Unknown', country: country)
        kind = OrganizationKind.first
        find_or_create_by!(name: 'Unknown', kind: kind, city: city, country: country)
      end
    end

    def merge_with_existing_department(to_organization_id, to_department_id)
      transaction do
        merge_with_existing_department!(to_organization_id, to_department_id)
      end
      true
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class}  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    def merge_with_new_department(to_id, name = self.name)
    transaction do
      merge_with_new_department!(to_id, name)
    end
    true
    rescue ActiveRecord::RecordInvalid => exception
      return false, "#{exception.record.class}  #{exception.message}"
    rescue MergeError, ActiveRecord::RecordNotFound => exception
      return false, exception.message
    end

    def merge_with_existing_department!(to_organization_id, to_department_id)
      department = OrganizationDepartment.find(to_department_id)
      if to_organization_id != department.organization_id
        raise MergeError, 'stale_organization_id'
      end
      merge_with_department!(department)
    end

    def merge_with_new_department!(to_id, name = self.name)
      department = OrganizationDepartment.new(name: name,
                                              organization_id: to_id,
                                              checked: true)
      merge_with_department!(department)
    end

    def merge_with_organization!(to_id)
      # raise MergeError, 'forbidden' if departments.exists?
      raise MergeError, 'same_object' if to_id == id
      Organization.find(to_id)
      merge_associations({ organization_id: id },
                         { organization_id: to_id },
                         Organization::MERGED_ASSOC +
                           [OrganizationDepartment])

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

    private

    # def skip_country_city_validations
    #
    # end

    def merge_with_department!(department)
      raise MergeError, 'forbidden' if departments.exists?
      department.save!
      merge_associations({ organization_id: id},
                         { organization_department: department,
                           organization_id: department.organization_id })
      destroy!
      department
    end

    def merge_associations(where_hash, update_hash, assocs = Organization::MERGED_ASSOC)
      assocs.each do |model_class|
        model_class.where(where_hash)
                   .each do |rec|
        rec.update!(update_hash)
        end
      end
      stat = ::Sessions::Stat.where where_hash.slice :organization_id
      stat.each do |rec|
        rec.update update_hash.slice :organization_id
      end

    end
  end
end
