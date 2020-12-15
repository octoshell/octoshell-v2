module CloudComputing
  module MassAssignment
    extend ActiveSupport::Concern
    UNASSIGNABLE_KEYS = %w[id _destroy].freeze

    def sentenced_to_death?(attributes)
      ActiveRecord::Type::Boolean.new.cast(attributes['_destroy'])
    end

    def assign_to_or_mark_for_destruction_for_positions(record, attributes)
      record.assign_attributes(attributes.except(*UNASSIGNABLE_KEYS))
      record.mark_for_destruction if sentenced_to_death?(attributes)
    end

    def raise_record_not_found!(record_id)
      model = CloudComputing::Position.name
      raise ActiveRecord::NotFound.new("Couldn't find #{model} with ID=#{record_id} for #{self.class.name} with ID=#{id}",
                               model, "id", record_id)
    end

    def assign_positions(user, attributes_collection)
      if attributes_collection.respond_to?(:permitted?)
        attributes_collection = attributes_collection.to_h
      end

      unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
        raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
      end

      if attributes_collection.is_a? Hash
        keys = attributes_collection.keys
        attributes_collection = if keys.include?("id") || keys.include?(:id)
          [attributes_collection]
        else
          attributes_collection.values
        end
      end

      attribute_ids = attributes_collection.map { |a| a["id"] || a[:id] }.compact
      existing_records = attribute_ids.empty? ? [] : positions.with_user_requests(user).where(id: attribute_ids).to_a

      attributes_collection.each do |attributes|
        attributes[:holder] = Request.find_or_initialize_by(status: 'created', created_by: user)
        if attributes.respond_to?(:permitted?)
          attributes = attributes.to_h
        end
        attributes = attributes.with_indifferent_access

        if attributes["id"].blank?
          unless sentenced_to_death?(attributes)
            existing_records << positions.new(attributes.except(*UNASSIGNABLE_KEYS))
          end
        elsif existing_record = existing_records.detect { |record| record.id.to_s == attributes["id"].to_s }
          assign_to_or_mark_for_destruction_for_positions(existing_record, attributes)
        else
          raise_record_not_found!(attributes["id"])
        end
      end
      existing_records
    end
  end
end
