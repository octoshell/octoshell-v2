module Support
  class FieldValuesForm
    include ActiveModel::Model
    attr_reader :topics_fields, :ticket

    validate do
      topics_fields.each do |t_f|
        next unless t_f.required

        t_f_id = t_f.id.to_s
        # puts TopicsField.find(t_f_id).field.inspect.red
        value = send(t_f_id)
        if t_f.field.check_box?
          errors.add(t_f_id, :invalid) if !value || value.select(&:present?).count.zero?
        elsif value.blank?
          errors.add(t_f_id, :invalid)
        end
      end
    end

    def initialize(ticket, hash = nil)
      @ticket = ticket
      if hash
        hash.permit! if hash.is_a? ActionController::Parameters
        @topics_fields = ticket.topics_fields_to_fill
        new_fields = TopicsField.includes(:field).where(id: hash.keys)
                                .where
                                .not(field_id: topics_fields.map(&:field_id))
                                .to_a
        @topics_fields += new_fields
        define_methods_for_topics_fields(topics_fields)
        fill_values(hash)
        # puts new_fields.inspect.red
        # puts topics_fields.inspect.green
      else
        @topics_fields = ticket.topics_fields_to_fill
        define_methods_for_topics_fields(topics_fields)
      end
    end

    def define_methods_for_topics_fields(current_topics_fields)
      current_topics_fields.each do |topics_field|
        define_singleton_method(topics_field.id.to_s) do
          ''
        end
      end
    end

    def fill_values(hash)
      hash.each do |topics_field_id, values|
        if values.is_a? Array
          present_values = values.select(&:present?)
          present_values.each do |value|
            ticket.field_values.new(topics_field_id: topics_field_id, value: value)
          end
          if present_values.empty?
            ticket.field_values.new(topics_field_id: topics_field_id)
          end
          define_singleton_method(topics_field_id.to_s) do
            present_values.map(&:to_i)
          end
        else
          ticket.field_values.new(topics_field_id: topics_field_id, value: values)
          define_singleton_method(topics_field_id.to_s) do
            values
          end
        end
      end
    end
  end
end
