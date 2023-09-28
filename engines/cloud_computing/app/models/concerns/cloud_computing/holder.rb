module CloudComputing
  module Holder

    extend ActiveSupport::Concern

    included do
      belongs_to :for, polymorphic: true
      has_many :items, as: :holder, inverse_of: :holder

      has_many :new_left_items, -> {
        left_outer_joins(:to_links).where(item_id: nil,
                                    cloud_computing_item_links: { id: nil })
      }, as: :holder, class_name: Item.to_s, inverse_of: :holder


      has_many :old_left_items, -> {
        left_outer_joins(:to_links).where(cloud_computing_item_links: { id: nil })
                             .where.not(item_id: nil)
      }, as: :holder, class_name: Item.to_s, inverse_of: :holder

      has_many :left_items, ->{ left_outer_joins(:to_links).where(cloud_computing_item_links: {id: nil})},
        as: :holder, class_name: Item.to_s, inverse_of: :holder

      accepts_nested_attributes_for :new_left_items, :old_left_items, allow_destroy: true
      validates :for, presence: true, unless: :created?
    end

    def finish_date_or_nil
      finish_date || I18n.t('cloud_computing.no_date')
    end

    def items_filled?
      items.all? do |item|
        item.template.editable_resources.count ==
          item.resource_items.count
      end
    end


  end
end
