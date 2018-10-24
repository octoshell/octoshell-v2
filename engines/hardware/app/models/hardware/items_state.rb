module Hardware
  class ItemsState < ActiveRecord::Base
    translates :reason
    belongs_to :state, inverse_of: :items_states
    belongs_to :item, inverse_of: :items_states
    validates :state, :item, presence: true

    def self.after(date)
      puts date.inspect
      return all unless date
      where('hardware_items_states.updated_at < ?', date)
    end
  end
end
