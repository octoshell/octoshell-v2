class ApplicationRecord < ActiveRecord::Base

  def self.inherited(subclass)
    subclass.has_paper_trail versions: { name: :paper_trail_versions },
                             version: :paper_trail_version
    super
  end

  self.abstract_class = true

  def self.interface(&block)
    instance_interface = Module.new(&block)
    include(instance_interface)
  end

  def self.extend_with_options
    has_many :options, as: :owner
    accepts_nested_attributes_for :options, allow_destroy: true
  end

end
