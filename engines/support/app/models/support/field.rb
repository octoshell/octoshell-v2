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

    translates :name, :hint

    validates_translated :name, presence: true

    def to_s
      name
    end
  end
end
