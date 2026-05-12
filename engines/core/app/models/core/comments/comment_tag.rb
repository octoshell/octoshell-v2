module Core
  module Comments
    class CommentTag < ApplicationRecord
      self.table_name = 'core_comment_tags'
      self.primary_key = nil

      belongs_to :comment,
                 class_name: 'Core::Comments::Comment',
                 foreign_key: :comment_id,
                 inverse_of: :comment_tags

      belongs_to :tag,
                 class_name: 'Core::Comments::Tag',
                 foreign_key: :tag_id,
                 inverse_of: :comment_tags

      validates :tag_id, uniqueness: { scope: :comment_id }
    end
  end
end
