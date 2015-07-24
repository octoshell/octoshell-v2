module Core
  class ProjectKind < ActiveRecord::Base
    validates :name, presence: true
  end
end
