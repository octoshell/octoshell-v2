class ApplicationRecord < ActiveRecord::Base

  def self.inherited(subclass)
    subclass.has_paper_trail versions: { name: :paper_trail_versions },
                             version: :paper_trail_version
    super
  end

  self.abstract_class = true

end
