module Core
  module Comments
    class Tag < ApplicationRecord
      self.table_name = 'core_tags'

      belongs_to :group,
                 class_name: 'Core::Comments::TagGroup',
                 foreign_key: :group_id,
                 inverse_of: :tags

      has_many :comment_tags,
               class_name: 'Core::Comments::CommentTag',
               foreign_key: :tag_id,
               inverse_of: :tag,
               dependent: :destroy

      has_many :comment_tags,
                class_name: 'Core::Comments::CommentTag',
                foreign_key: :tag_id,
                dependent: :delete_all     

      has_many :comments,
               through: :comment_tags,
               class_name: 'Core::Comments::Comment',
               source: :comment

      validates :key, presence: true, uniqueness: { scope: :group_id }
      validates :label, presence: true
      validates :is_active, inclusion: { in: [true, false] }
      validates :sort_order, presence: true

      scope :active, -> { where(is_active: true) }
    end
  end
end
