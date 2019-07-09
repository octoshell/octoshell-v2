# == Schema Information
#
# Table name: hardware_states
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
  class State < ActiveRecord::Base

    has_paper_trail

    belongs_to :kind, inverse_of: :states
    has_and_belongs_to_many :from_states, class_name: 'State',
                                          join_table: :hardware_states_links,
                                          foreign_key: :to_id,
                                          association_foreign_key: :from_id,
                                          dependent: :destroy
    has_and_belongs_to_many :to_states, class_name: 'State',
                                        join_table: :hardware_states_links,
                                        foreign_key: :from_id,
                                        association_foreign_key: :to_id,
                                        dependent: :destroy
    has_many :items_states, dependent: :restrict_with_error, inverse_of: :state
    has_many :items, through: :items_states, source: :item, inverse_of: :states



    translates :name, :description, fallback: :any
    validates :name_ru, uniqueness: { scope: :kind_id }, if: proc { |k| k.name_ru.present? }
    validates :name_en, uniqueness: { scope: :kind_id }, if: proc { |k| k.name_en.present? }
    validates_translated :name, presence: true
    validates :name, :kind, presence: true
    validate do
      if from_states.include? self
        errors.add :from_state_ids, I18n.t('hardware.self_error')
      end

      if to_states.include? self
        errors.add :to_state_ids, I18n.t('hardware.self_error')
      end
    end
    def as_json(_options)
      { id: id, text: name }
    end

  end
end
