module Comments
  class Tag < ActiveRecord::Base
    validates :name, presence: true
    has_many :taggings, inverse_of: :tag
    def self.allowed_names(user_id)
      Tagging.allowed(user_id).map{ |tagging| tagging.tag.name }
    end
  end
end
