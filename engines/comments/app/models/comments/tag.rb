module Comments
  class Tag < ActiveRecord::Base
    validates :name, presence: true
    has_many :taggings, inverse_of: :tag
  end
end
