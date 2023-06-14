module Core
  module ProjectVersionHelper
    def object_changes(raw_hash)
      res = raw_hash.map do |key, value|
        new_key = Project.human_attribute_name(key)
        new_value = value
        if value.is_a?(Hash) && key == 'card'
          new_value = value.map do |k, v|
            v = v.map(&:to_s) if v.any? { |v| v.is_a? ActiveSupport::TimeWithZone}
            [Core::ProjectCard.human_attribute_name(k), v]
          end.to_h
        elsif value.all? { |v| v.is_a? Array }
          klass = Core::Project.reflect_on_association(key).klass
          new_value = value.map { |a| klass.where(id: a).map(&:name) }
          new_value = new_value.map(&:to_s)
        elsif value.any? { |v| v.is_a? ActiveSupport::TimeWithZone }
          new_value = value.map(&:to_s)
        end
        [new_key, new_value]
      end.to_h
      space = '&nbsp;'
      k = 9
      simple_format res.to_yaml(indentation: k).gsub(' ', space)

    end


  end
end
