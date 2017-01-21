module Pack
  class Prop < ActiveRecord::Base
  	enum proj_or_user: [:user,:project]
  	validates :proj_or_user, :user_id,presence: true
  	validates  :user_id,uniqueness: true
  end
end
