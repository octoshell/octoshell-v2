module Wikiplus
  class Page < ApplicationRecord
    def test
      return id
    end

  	has_many :subpages, class_name: "Page",
                        foreign_key: "mainpage_id"

    belongs_to :mainpage, class_name: "Page"

    translates :name, :content
    validates_translated :content, :name, presence: true
    validates :url, presence: true, uniqueness: true

    def to_param
      "#{id}-#{url}"
    end
  end
end
