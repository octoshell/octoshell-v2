# This migration comes from pack (originally 20170302113325)
class AddDateToVersions < ActiveRecord::Migration
  def change
  	remove_column :pack_versions,:end_lic
   	add_column :pack_versions,:end_lic,:date

  end
end
