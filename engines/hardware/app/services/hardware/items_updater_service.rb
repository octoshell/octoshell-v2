module Hardware
  class ItemsUpdaterService

    def self.delete!(hash, key)
      value = hash.fetch(key)
      hash.delete(key)
      value
    end

    def self.kinds(array)
      ActiveRecord::Base.transaction do
        update! array
      end
    end


    def self.from_a(array)
      ActiveRecord::Base.transaction do
        update! array
      end
    end

    def self.to_a(records = Item.all)
      records.map do |r|
        r.attributes.except('lock_version').merge(state: r&.last_items_state&.attributes&.except('id', 'item_id'))
      end
    end


    def self.update!(array)
      errors=[]
      array.each do |attributes|
        state_attributes = attributes.delete('state')
        id = attributes.delete('id')
        if id.present?
          item = Item.find(id)
          item.update!(attributes)
        else
          begin
            item = Item.create!(attributes)
          rescue => e
            errors << "#{e.message} (#{attributes.inspect})"
            next
          end
        end
        # item.last_items_state
        update_state(item, state_attributes) if state_attributes
      end
      errors
    end

    def self.update_state(item, hash)
      if !hash['state_id'] || hash['state_id'].to_i == item.last_items_state&.state_id
        item.last_items_state.update!(hash)
      else
        item.items_states.create!(hash)
      end
    end
  end
end
