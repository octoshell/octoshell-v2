class ChangePermissions < ActiveRecord::Migration[5.2]
  def change
    rename_column :permissions, :subject, :subject_class
    add_column :permissions, :subject_id, :integer
  end
end
