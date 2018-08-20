# Тег тикета
module Support
  class Tag < ActiveRecord::Base
    attr_accessor :merge_id

    translates :name

    has_and_belongs_to_many :tickets, join_table: :support_tickets_tags
    has_and_belongs_to_many :topics, join_table: :support_topics_tags

    validates_translated :name, presence: true

    def merge_with(tag)
      return false if self == tag

      transaction do
        Ticket.joins(:tags).where(tags: { id: tag.id }).find_each do |ticket|
          ticket.tags << self
        end

        Topics.joins(:tags).where(tags: { id: tag.id }).find_each do |topic|
          topic.tags << self
        end

        tag.destroy
      end
    end

    def to_s
      name
    end
  end
end
