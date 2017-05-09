# This migration comes from pack (originally 20170507184826)
class AddBehavExp2 < ActiveRecord::Migration
  def change
  		remove_column :pack_versions,:delete_on_expire
  	  	add_column :pack_versions,:delete_on_expire,:boolean,default: false
  end
end
