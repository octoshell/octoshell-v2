# == Schema Information
#
# Table name: comments_context_groups
#
#  id         :integer          not null, primary key
#  context_id :integer          not null
#  group_id   :integer          not null
#  type_ab    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Comments
  class ContextGroup < ActiveRecord::Base
    belongs_to :context
    belongs_to :group
    enum type_ab: %i[read_ab update_ab create_ab]
    validates :group_id, uniqueness: { scope: %i[context_id type_ab] }
    validate do
        # where(group_id: group_id, context_id: context_id, type_ab: read_type_abs)
    end
    def read_type_abs
      type_abs.slice(:read_ab, :update_ab).values
    end
  end
end
