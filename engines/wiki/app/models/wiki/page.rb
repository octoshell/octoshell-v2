module Wiki
  class Page < ActiveRecord::Base

    translates :name, :content

    validates :content, :name, :url, presence: true
    validates :url, uniqueness: true

    def to_param
      "#{id}-#{url}"
    end
  end
end
