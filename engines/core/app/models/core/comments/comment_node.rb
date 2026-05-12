module Core
  module Comments
    class CommentNode < ApplicationRecord
      self.table_name = 'core_comments_nodes'

      belongs_to :comment,
                 class_name: 'Core::Comments::Comment',
                 foreign_key: :comment_id,
                 inverse_of: :comment_nodes

      belongs_to :node,
                 class_name: 'Core::Analytics::Node',
                 foreign_key: :node_id

      validates :node_id, uniqueness: { scope: :comment_id }

      validate :node_must_belong_to_comment_system

      private

      def node_must_belong_to_comment_system
        return if comment.blank? || node.blank?
        return if node.cluster_id.to_i == comment.cluster_id.to_i

        errors.add(:node_id, 'узел должен принадлежать той же системе, что и комментарий')
      end
    end
  end
end
