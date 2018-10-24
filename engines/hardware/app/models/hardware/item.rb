module Hardware
  class Item < ActiveRecord::Base
    translates :name, :description
    belongs_to :kind, inverse_of: :items
    has_many :items_states, inverse_of: :item
    has_many :states, through: :items_states, source: :state

    # has_many :now_state, -> { order('updated_at DESC').limit(1) },
    #          through: :items_states,
    #          source: :state
    #
    validates :name_ru, uniqueness: { scope: :kind_id }, if: proc { |k| k.name_ru.present? }
    validates :name_en, uniqueness: { scope: :kind_id }, if: proc { |k| k.name_en.present? }
    validates_translated :name, presence: true
    validates :name, :kind, :kind_id, presence: true

    validate do
      items_states.map(&:state).each do |state|
        unless state.kind == kind
          errrors.add(:kind, :invalid)
          break
        end
      end
    end

    def self.current_state_date(*val)
      val = val.select(&:present?)
      if val.any?
        joins("INNER JOIN hardware_items_states AS i_s ON i_s.item_id = hardware_items.id AND i_s.state_id IN (#{val.join(',')}) ")
      else
        joins("INNER JOIN hardware_items_states AS i_s ON i_s.item_id = hardware_items.id")
      end.joins(:items_states)
      .group("hardware_items.id, i_s.id")
      .having("MAX(hardware_items_states.updated_at) = i_s.updated_at")
    end

    def self.ransackable_scopes(_auth_object)
      %i[current_state_date]
    end

    def to_states
      states&.last&.to_states || kind.states
    end

  end
end
