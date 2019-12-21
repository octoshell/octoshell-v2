# This migration comes from core (originally 20190912165817)
class AddGroupIdToCoreResearchAreas < ActiveRecord::Migration[5.2]
  def change
    add_reference :core_research_areas, :group, index: true
  end
end
