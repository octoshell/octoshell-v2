# == Schema Information
#
# Table name: wiki_pages
#
#  id         :integer          not null, primary key
#  name_ru    :string(255)
#  content_ru :text
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name_en    :string
#  content_en :text
#

module Wiki
  class Page < ActiveRecord::Base

    translates :name, :content
    validates_translated :content, :name, presence: true
    validates :url, presence: true, uniqueness: true

    def to_param
      "#{id}-#{url}"
    end
  end
end
