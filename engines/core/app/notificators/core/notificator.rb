module Core
  class Notificator < ::Support::Notificator

    def topic_name
      t('.topic').freeze
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
