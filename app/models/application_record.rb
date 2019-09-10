class ApplicationRecord < ActiveRecord::Base

  def self.inherited(subclass)
    subclass.has_paper_trail
    super
  end

  self.abstract_class = true

end
