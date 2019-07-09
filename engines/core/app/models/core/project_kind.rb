# == Schema Information
#
# Table name: core_project_kinds
#
#  id      :integer          not null, primary key
#  name_ru :string(255)
#  name_en :string
#

module Core
  class ProjectKind < ActiveRecord::Base

    has_paper_trail

    translates :name
    validates_translated :name, presence: true
  end
end
