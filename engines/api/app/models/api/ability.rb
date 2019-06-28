module Api
  class Ability < ActiveRecord::Base
    has_and_belongs_to_many :exports
  end
end
