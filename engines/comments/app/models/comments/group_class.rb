# == Schema Information
#
# Table name: comments_group_classes
#
#  id         :integer          not null, primary key
#  allow      :boolean          not null
#  class_name :string
#  type_ab    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer
#  obj_id     :integer
#
# Indexes
#
#  index_comments_group_classes_on_group_id  (group_id)
#

module Comments
  class GroupClass < ApplicationRecord
    old_enum type_ab: %i[read_ab update_ab create_ab create_with_context_ab]
    belongs_to :group
    validates :type_ab, presence: true
    validates :group, uniqueness: { scope: %i[class_name obj_id type_ab] }
    validates :allow, exclusion: { in: [nil] }
    validate :validate_class_name

    def read_type_abs
      type_abs.slice(:read_ab, :update_ab).values
    end

    def validate_class_name
      b =  Object.const_defined?(class_name) && eval(class_name) < ApplicationRecord
    rescue NameError, ArgumentError
      b = false
    ensure
      errors.add(:class_name, :not_exist) unless b
    end
    # 1 как должно быть
    # 1р2з t f 1з2р f t 2р1з f f 2з1п f t

    def self.create_permissions_query(class_name, id, user_id, type_ab_sym)
      type_ab = GroupClass.type_abs[type_ab_sym]
      select("#{table_name}.*")
        .where("
        #{table_name}.class_name = '#{class_name}' AND
        (#{table_name}.obj_id IS NULL OR
          #{table_name}.obj_id = #{id})
          AND #{table_name}.group_id IS NULL
          AND #{table_name}.type_ab =  (#{type_ab})")
        .joins("LEFT JOIN user_groups AS u_g ON u_g.user_id = #{user_id}")
        .joins("LEFT JOIN comments_group_classes AS g_c ON
        g_c.class_name = '#{class_name}' AND
        (g_c.obj_id IS NULL OR g_c.obj_id = #{id})
        AND g_c.group_id = u_g.group_id
        AND g_c.type_ab = (#{type_ab})")
        .where("( #{table_name}.allow = 'f' AND g_c.allow = 't' OR
                #{table_name}.allow = 't' AND ( g_c.allow = 't' OR g_c.id IS NULL))")
        .exists?
    end

    def self.create_permissions(class_name, id, user_id)
      if create_permissions_query(class_name, id, user_id, :create_with_context_ab)
        :create_with_context
      elsif create_permissions_query(class_name, id, user_id, :create_ab)
        true
      else
        false
      end
    end
  end
end
