# == Schema Information
#
# Table name: comments_contexts
#
#  id         :integer          not null, primary key
#  name_ru    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_en    :string
#

module Comments
  class Context < ActiveRecord::Base

    has_paper_trail

    has_many :context_groups, dependent: :destroy
    translates :name
    validates_translated :name, presence: true
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
