class RenameResearchAreasGroup < ActiveRecord::Migration[5.2]
  def change
    rename_column :core_research_areas, :group, :old_group
  end
end
