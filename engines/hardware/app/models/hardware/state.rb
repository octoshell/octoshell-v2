module Hardware
  class State < ActiveRecord::Base
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



    translates :name, :description
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
