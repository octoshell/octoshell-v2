class CreateCoreGroupOfResearchAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :core_group_of_research_areas do |t|
      t.string :name_en
      t.string :name_ru
      t.timestamps
    end
  end
end
