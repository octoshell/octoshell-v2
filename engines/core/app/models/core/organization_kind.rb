module Core
  class OrganizationKind < ActiveRecord::Base
    has_many :organizations, foreign_key: :kind_id

    translates :name
    validates_translated :name, presence: true
    def to_s
      name
    end
  end
end
