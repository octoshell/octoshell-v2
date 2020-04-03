module Core
  if Octoface.role_class?(:support, 'Notificator')
    class Notificator < Octoface.role_class(:support, 'Notificator')
      def self.name_ru
        'Проверить новую запись'
      end

      def self.name_en
        'Check new record'
      end


      def topic
        Support::Topic.find_or_create_by!(name_ru: self.class.name_ru,
                                          name_en: self.class.name_en,
                                          parent_topic: parent_topic)
      end

      def check(object, current_user)
        @object = object
        name = @object.model_name.to_s.split('::').last.downcase.pluralize
        if name == 'organizationdepartments'
          name = 'organizations'
          id = @object.organization_id
        else
          id = @object.id
        end
        @url = "/core/admin/#{name}/#{id}"
        hash = { subject: t('.subject', model_name: @object.model_name.human, to_s: @object.to_s) }
        hash[:reporter] = current_user
        hash
      end
    end
  end
end
