module Comments
  module Permissions
    def self.create_permissions(class_name:, ids:, user:)
      return false unless ids.count == 1

      GroupClass.create_permissions(class_name, ids.first, user.id)
    end

    # def self.attachable_with_permission(model, class_name, ids, user_id )
    #   Context
    # end

    def self.get_defaults(class_name, ids, user_id)
      str = ids.join(',')
      GroupClass.joins("LEFT JOIN user_groups AS u_g ON u_g.user_id=#{user_id}")
                .where("class_name = '#{class_name}' AND (id IN (#{str}) OR id IS_NULL )")
    end
  end
end
