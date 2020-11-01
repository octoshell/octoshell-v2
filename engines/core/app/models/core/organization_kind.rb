# == Schema Information
#
# Table name: core_organization_kinds
#
#  id                   :integer          not null, primary key
#  departments_required :boolean          default(FALSE)
#  name_en              :string
#  name_ru              :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

module Core
  class OrganizationKind < ApplicationRecord
    has_many :organizations, foreign_key: :kind_id

    translates :name
    validates_translated :name, presence: true
    def to_s
      name
    end
  end
end
