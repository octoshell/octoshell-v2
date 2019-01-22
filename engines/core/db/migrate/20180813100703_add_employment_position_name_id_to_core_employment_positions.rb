class AddEmploymentPositionNameIdToCoreEmploymentPositions < ActiveRecord::Migration
  def change
    add_column :core_employment_positions, :employment_position_name_id, :integer
  end
end
