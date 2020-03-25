# This migration comes from pack (originally 20180603154228)
class AddNewEndLicForeverToAccesses < ActiveRecord::Migration[4.2]
  def change
    add_column :pack_accesses, :new_end_lic_forever, :boolean, default: false
  end
end
