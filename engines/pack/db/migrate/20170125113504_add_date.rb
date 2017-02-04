class AddDate < ActiveRecord::Migration
  def change
  	add_column :pack_props,:def_date,:string
  	add_column :pack_accesses,:end_lic,:string
  	add_column :pack_accesses,:begin_lic,:string

  end
end
