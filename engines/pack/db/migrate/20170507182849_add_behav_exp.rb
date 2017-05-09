class AddBehavExp < ActiveRecord::Migration
  def change
  	add_column :pack_versions,:delete_on_expire,:boolean,default: false,null: false
  end
end
