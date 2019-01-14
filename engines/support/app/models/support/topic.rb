# endcoding: utf-8

module Support
  class Topic < ActiveRecord::Base

    translates :name, :template

    belongs_to :parent_topic, class_name: "Support::Topic", foreign_key: :parent_id, inverse_of: :subtopics
    has_many :subtopics, class_name: "Support::Topic", foreign_key: :parent_id,
                         inverse_of: :parent_topic, dependent: :destroy
    has_and_belongs_to_many :fields, join_table: :support_topics_fields
    has_and_belongs_to_many :tags, join_table: :support_topics_tags
    has_and_belongs_to_many :responsible_users,class_name: '::User',
                            join_table: :support_user_topics

    has_many :user_topics, dependent: :destroy
    accepts_nested_attributes_for :user_topics, allow_destroy: true
    validates_translated :name, presence: true
    validates :parent_id, exclusion: { in: proc { |tq| [tq.id] } }, allow_nil: true
    validate do
      length = user_topics.select(&:required).length
      if length > 1
        errors.add(:user_topic_ids, I18n.t("errors.choose_at_max", count: 1 ))
      end
    end

    scope :root, -> { where(parent_id: nil) }
    scope :visible_root, -> { where(parent_id: nil, visible_on_create: true) }
    scope :common_theme, -> { where(name_ru: "Другое") }

    def available_parents
      new_record? ? Topic.all : Topic.where.not(id: id)
    end

    def visible_subtopics
      subtopics.where(visible_on_create: true)
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

    def parents_with_self
      array = [self]
      parent = parent_topic
      until parent.nil?
        array << parent
        parent = parent.parent_topic
      end
      array
    end
  end
end
