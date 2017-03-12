module Pack
  class Prop < ActiveRecord::Base
  	enum proj_or_user: [:user,:project]
  	validates :proj_or_user, :user_id,presence: true
  	validates  :user_id,uniqueness: true
  	validates_format_of :def_date, :with => /(\A\d{2}.\d{2}.\d{4}\Z)|(\A\Z)/, :allow_nil => true
  end
end
