module Hardware
  class ItemsState < ActiveRecord::Base
    translates :reason
    belongs_to :state, inverse_of: :items_states
    belongs_to :item, inverse_of: :items_states
    validates :state, :item, presence: true
  end
end
