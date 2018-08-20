# endcoding: utf-8

module Support
  class Topic < ActiveRecord::Base

    translates :name

    belongs_to :parent_topic, class_name: "Support::Topic", foreign_key: :parent_id, inverse_of: :subtopics
    has_many :subtopics, class_name: "Support::Topic", foreign_key: :parent_id,
                         inverse_of: :parent_topic, dependent: :destroy

    has_and_belongs_to_many :fields, join_table: :support_topics_fields
    has_and_belongs_to_many :tags, join_table: :support_topics_tags

    validates_translated :name, presence: true
    validates :parent_id, exclusion: { in: proc { |tq| [tq.id] } }, allow_nil: true

    scope :root, -> { where(parent_id: nil) }
    scope :common_theme, -> { where(name: "Другое") }

    def available_parents
      new_record? ? Topic.all : Topic.where.not(id: id)
    end

    def name_with_parents
      names = []
      names << name
      p_topic = parent_topic
      until p_topic.nil?
        names << p_topic.name
        p_topic = p_topic.parent_topic
      end

      names.reverse.join(" > ")
    end

    def self.leaf_topics
      Topic.all.select{|t| t.subtopics.empty? }
    end

    def to_s
      name
    end
  end
end
