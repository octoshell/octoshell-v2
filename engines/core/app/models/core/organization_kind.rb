module Core
  class OrganizationKind < ActiveRecord::Base
    has_many :organizations, foreign_key: :kind_id

    def to_s
      name
    end
  end
end
