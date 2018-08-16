class AddFieldIdToCoreEmploymentPositions < ActiveRecord::Migration
  def change
    add_column :core_employment_positions, :field_id, :integer
  end
end
