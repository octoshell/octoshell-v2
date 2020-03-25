# This migration comes from core (originally 20190912165352)
class RenameResearchAreasGroup < ActiveRecord::Migration[5.2]
  def change
    rename_column :core_research_areas, :group, :old_group
  end
end
