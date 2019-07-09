# == Schema Information
#
# Table name: comments_context_groups
#
#  id         :integer          not null, primary key
#  type_ab    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  context_id :integer          not null
#  group_id   :integer          not null
#
# Indexes
#
#  index_comments_context_groups_on_context_id  (context_id)
#  index_comments_context_groups_on_group_id    (group_id)
#

module Comments
  class ContextGroup < ActiveRecord::Base

    has_paper_trail

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
