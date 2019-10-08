# == Schema Information
#
# Table name: support_fields
#
#  id                   :integer          not null, primary key
#  name_ru              :string(255)
#  hint_ru              :string(255)
#  required             :boolean          default(FALSE)
#  contains_source_code :boolean          default(FALSE)
#  url                  :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  name_en              :string
#  hint_en              :string
#

module Support
  class Field < ApplicationRecord
    has_and_belongs_to_many :topics, join_table: :support_topics_fields
    has_many :field_options, inverse_of: :field, dependent: :destroy
    has_many :topics_fields, inverse_of: :field, dependent: :destroy
    has_many :field_values, through: :topics_fields, dependent: :destroy

    accepts_nested_attributes_for :field_options, allow_destroy: true
    translates :name, :hint
    validates_translated :name, presence: true

    validate do
      any_options = field_options.to_a.select { |o| !o.marked_for_destruction?  }.any?
      %i[url contains_source_code model_collection].each do |a|
        any_options && send(a).present? &&
          errors.add(a, :field_options_present)
      end
      %i[url contains_source_code].each do |a|
        model_collection.present? && send(a).present? &&
          errors.add(a, :collection_present)
      end
    end

    scope :searchable_fields,( lambda do |ids|
      Support::Field.where(id: ids).distinct.includes(:field_options)
    end)

    def field_type
      return 'model_collection' if model_collection.present?

      return 'field_options' if field_options.any?

      'text'
    end


    def to_s
      name
    end
  end
end
