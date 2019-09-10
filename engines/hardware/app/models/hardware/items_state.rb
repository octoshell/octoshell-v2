# == Schema Information
#
# Table name: hardware_items_states
#
#  id             :integer          not null, primary key
#  item_id        :integer
#  state_id       :integer
#  reason_en      :text
#  reason_ru      :text
#  description_en :text
#  description_ru :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

module Hardware
  class ItemsState < ApplicationRecord
    translates :reason, :description, fallback: :any
    belongs_to :state, inverse_of: :items_states
    belongs_to :item, inverse_of: :items_states
    validates :state, :item, presence: true

    validate do
      if item && state
        if item.kind != state.kind || item.to_states.exclude?(state) && new_record?
          errors.add(:state_id, :invalid)
        end
      end
    end

    def self.after(date)
      return all unless date
      where('hardware_items_states.created_at < ?', date)
    end
  end
end
