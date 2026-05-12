module Core
  module Comments
    class TagGroup < ApplicationRecord
      self.table_name = 'core_tag_groups'

      has_many :tags,
               class_name: 'Core::Comments::Tag',
               foreign_key: :group_id,
               inverse_of: :group,
               dependent: :destroy

      validates :key, presence: true, uniqueness: true
      validates :name, presence: true
      validates :is_active, inclusion: { in: [true, false] }
      validates :sort_order, presence: true

      scope :active, -> { where(is_active: true).order(:sort_order, :id) }
    end
  end
end
