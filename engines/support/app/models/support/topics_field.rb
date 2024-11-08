# == Schema Information
#
# Table name: support_topics_fields
#
#  id       :integer          not null, primary key
#  required :boolean          default(FALSE)
#  field_id :integer
#  topic_id :integer
#
module Support
  class TopicsField < ApplicationRecord
    belongs_to :field, inverse_of: :topics_fields
    belongs_to :topic, inverse_of: :topics_fields
    has_many :field_values, inverse_of: :topics_field
    # translates :name
    # validates_translated :name, presence: true
  end
end
