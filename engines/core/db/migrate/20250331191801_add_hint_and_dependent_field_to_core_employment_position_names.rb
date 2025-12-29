class AddHintAndDependentFieldToCoreEmploymentPositionNames < ActiveRecord::Migration[5.2]
  def change
    add_column :core_employment_position_names, :hint_ru, :string
    add_column :core_employment_position_names, :hint_en, :string
    add_column :core_employment_position_names, :if_empty_fill_id, :integer
  end
end
