module CloudComputing
  class ItemLink < ApplicationRecord
    belongs_to :from, class_name: 'CloudComputing::Position', inverse_of: :from_links
    belongs_to :to, class_name: 'CloudComputing::Position', inverse_of: :to_links, dependent: :destroy, autosave: true

    validate do

    end

    def to_item_id
      to&.item_id
    end

    def to_item_id=(item_id)
      self.to ||= Position.new(holder: from.holder)
      to.item_id = item_id
    end

    before_validation do
      to.amount = amount * from.amount
      to.holder = from.holder
    end
  end
end
