module Hardware
  class ItemsState < ActiveRecord::Base
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
