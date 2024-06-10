module Core
  if Octoface.role_class?(:support, 'Notificator')
    class Notificator < Octoface.role_class(:support, 'Notificator')
      def self.topic_ru
        'Проверить новую запись'
      end

      def self.topic_en
        'Check new record'
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
        { subject: t('.subject', model_name: @object.model_name.human,
                                 to_s: @object.to_s),
          reporter: current_user }
      end
    end
  end
end
