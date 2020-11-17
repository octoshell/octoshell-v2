module CloudComputing
  class ItemKind < ApplicationRecord
    acts_as_nested_set
    has_many :conditions, as: :from, dependent: :destroy
    has_many :items, inverse_of: :item_kind, dependent: :destroy

    accepts_nested_attributes_for :conditions, allow_destroy: true

    translates :name, :description
    validates_translated :name, presence: true, uniqueness: { scope: :parent_id }
    def child_index=(idx)
      return if new_record?

      if parent
        move_to_child_with_index(parent, idx.to_i)
      else
        move_to_root_with_index(idx.to_i)
      end
    end

    def move_to_root_with_index(index)
      roots = self.class.roots
      if roots.count == index
        move_to_right_of(roots.last)
      else
        my_position = roots.to_a.index(self)
        if my_position && my_position < index
          move_to_right_of(roots[index])
        elsif my_position && my_position == index
          # do nothing. already there.
        else
          move_to_left_of(roots[index])
        end
      end
    end

    def to_s
      name
    end
  end
end
