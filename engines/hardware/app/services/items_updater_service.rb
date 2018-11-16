module Hardware
  class ItemsUpdaterService

    def self.delete!(hash, key)
      value = hash.fetch(key)
      hash.delete(key)
      value
    end

    def self.update!(array)
      array.each do |attributes|
        state_attributes = attributes.delete('state')
        id = attributes.delete('id')
        if id.present?
          item = Item.find(id)
          item.update!(attributes)
        else
          item = Item.create!(attributes)
        end
        # item.last_items_state
        update_state(item, state_attributes) if state_attributes
      end
    end

    def self.update_state(item, hash)
      if !hash['state_id'] || hash['state_id'].to_i == item.last_items_state&.id
        item.last_items_state.update!(hash)
      else
        item.items_states.create!(hash)
      end
    end
  end
end
