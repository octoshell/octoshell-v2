class DropOrganizationFromCoreSureties < ActiveRecord::Migration
  def change
    remove_column :core_sureties, :organization_id
  end
end
