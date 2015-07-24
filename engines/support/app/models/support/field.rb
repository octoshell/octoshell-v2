module Support
  class Field < ActiveRecord::Base
    has_and_belongs_to_many :topics, join_table: :support_topics_fields

    validates :name, presence: true

    def hint
      self[:hint].presence
    end

    def to_s
      name
    end
  end
end
