module CloudComputing
  module Holder
    extend ActiveSupport::Concern
    included do
      belongs_to :for, polymorphic: true
      has_many :positions, as: :holder, inverse_of: :holder
      has_many :left_positions, ->{ left_joins(:to_links).where(cloud_computing_position_links: {id: nil})},
        as: :holder, class_name: Position.to_s, inverse_of: :holder

      accepts_nested_attributes_for :left_positions, allow_destroy: true
      validates :for, presence: true, unless: :created?
    end

    def finish_date_or_nil
      finish_date || I18n.t('cloud_computing.no_date')
    end

    def positions_filled?
      positions.all? do |position|
        position.item.editable_resources.count ==
          position.resource_positions.count
      end
    end


  end
end
