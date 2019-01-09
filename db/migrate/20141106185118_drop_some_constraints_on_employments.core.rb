# This migration comes from core (originally 20141106184946)
class DropSomeConstraintsOnEmployments < ActiveRecord::Migration
  def change
    change_column_null :core_employments, :organization_department_id, true
  end
end
