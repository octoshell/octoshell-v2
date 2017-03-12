class AddDateToVersions < ActiveRecord::Migration
  def change
  	add_column :pack_versions,:end_lic,:date, null: false
  end
end
