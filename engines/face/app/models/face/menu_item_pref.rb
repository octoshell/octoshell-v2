module Face
  class MenuItemPref < ApplicationRecord
    belongs_to :user, class_name: 'User'
    validates :position, :menu, :position, :key, presence: true
    validates :user, presence: true, unless: proc { |pref| pref.admin }
    validates :user_id, uniqueness: { scope: %i[menu admin key] }

    before_validation do
      self.user = nil if admin
    end

    def self.last_position
      order(position: :desc).first&.position || -1
    end

    def self.edit_all(keys, conditions)
      ActiveRecord::Base.transaction do
        items = where(conditions).to_a
        keys.each_with_index do |key, position|
          item = items.detect { |i| i.key == key }
          if item
            items.delete item
          else
            item = new(conditions.merge(key: key))
          end
          item.update!(position: position)
        end
        max_pos = keys.length
        items.each do |item|
          item.update!(position: max_pos)
          max_pos += 1
        end
      end
    end

  end
end
