# == Schema Information
#
# Table name: core_organization_kinds
#
#  id                   :integer          not null, primary key
#  name_ru              :string(255)
#  departments_required :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  name_en              :string
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
