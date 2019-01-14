module Core
  class ProjectKind < ActiveRecord::Base
    translates :name
    validates_translated :name, presence: true
  end
end
