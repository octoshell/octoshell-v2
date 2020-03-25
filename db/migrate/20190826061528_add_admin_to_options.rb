class AddAdminToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :admin, :boolean, default: false
  end
end
