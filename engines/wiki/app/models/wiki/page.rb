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
