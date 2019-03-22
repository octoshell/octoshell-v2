# == Schema Information
#
# Table name: hardware_items
#
#  id             :integer          not null, primary key
#  name_ru        :string
#  name_en        :string
#  description_ru :text
#  description_en :text
#  lock_version   :integer
#  kind_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

module Hardware
  class Item < ApplicationRecord
    translates :name, :description, fallback: :any
    belongs_to :kind, inverse_of: :items

    has_many :items_states, inverse_of: :item
    has_many :states, through: :items_states, source: :state, inverse_of: :items
    has_many :options, as: :owner
    accepts_nested_attributes_for :options, allow_destroy: true


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
      val = val.select(&:present?).map { |elem| elem == true ? 1 : elem  }
      if val.any?
        joins("INNER JOIN hardware_items_states AS i_s ON i_s.item_id = hardware_items.id AND i_s.state_id IN (#{val.join(',')}) ")
      else
        joins("INNER JOIN hardware_items_states AS i_s ON i_s.item_id = hardware_items.id")
      end.joins(:items_states)
      .group("hardware_items.id, i_s.id")
      .having("MAX(hardware_items_states.created_at) = i_s.created_at")
    end

    def self.current_state_date(*val)
      val = val.select(&:present?).map { |elem| elem == true ? 1 : elem  }
      where("i_s.state_id IN (#{val.join(',')})")
    end

    def self.joins_last_state
      joins("LEFT JOIN hardware_items_states AS i_s  ON i_s.item_id = hardware_items.id")
      .joins("LEFT JOIN hardware_items_states AS i_s2 ON (hardware_items.id = i_s2.item_id AND
    (i_s.updated_at < i_s2.updated_at OR i_s.updated_at = i_s2.updated_at AND i_s.id < i_s2.id))")
      .where("i_s2.id IS NULL")
    end

    def self.only_deleted(val)
      j = joins_last_state
      .joins("LEFT JOIN hardware_states ON i_s.state_id = hardware_states.id")
      if val == 'only_deleted'
        j.where("hardware_states.name_en = '#{Hardware::DELETED[:name_en]}'")
      else
        j.where("hardware_states.name_en !=
          '#{Hardware::DELETED[:name_en]}' OR hardware_states.id IS NULL")
      end
    end


    def self.ransackable_scopes(_auth_object)
      %i[current_state_date only_deleted]
    end

    def to_states
      last_items_state&.state&.to_states || kind.states
    end

    def last_items_state
      items_states.select(&:id)&.last
    end

    def last_items_state_after(date)
      items_states.after(date).last
    end


    def self.after(date)
      return all unless date
      where('hardware_items_states.created_at < ?', date)
    end

    def self.after_or(date)
      return all unless date
      where('hardware_items_states.created_at < ? OR hardware_items_states.id IS NULL', date)
    end


  end
end
