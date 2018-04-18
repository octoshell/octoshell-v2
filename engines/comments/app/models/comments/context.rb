module Comments
  class Context < ActiveRecord::Base
    has_many :context_groups, dependent: :destroy

    def self.context_id_valid?(user, context_id)
      Context.allow(user.id).where(id: context_id).exists?
    end

    def self.allow(user_id)
      type_ab_int = ContextGroup.type_abs[:create_ab]
      joins(context_groups: { group: :user_groups })
      .where("user_groups.user_id = #{user_id}
        AND comments_context_groups.type_ab = #{type_ab_int}").distinct
    end
    
    def self.allow_read(user_id)
      type_ab_int = ContextGroup.type_abs[:read_ab]
      joins(context_groups: { group: :user_groups })
      .where("user_groups.user_id = #{user_id}
        AND comments_context_groups.type_ab = #{type_ab_int}").distinct
    end
  end
end
