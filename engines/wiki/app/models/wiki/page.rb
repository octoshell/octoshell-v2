# == Schema Information
#
# Table name: wiki_pages
#
#  id         :integer          not null, primary key
#  content_en :text
#  content_ru :text
#  name_en    :string
#  name_ru    :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_wiki_pages_on_url  (url) UNIQUE
#

module Wiki
  class Page < ApplicationRecord

    

    translates :name, :content
    validates_translated :content, :name, presence: true
    validates :url, presence: true, uniqueness: true

    def to_param
      "#{id}-#{url}"
    end
  end
end
