# This migration comes from core (originally 20140824085006)
class DropOrganizationFromCoreSureties < ActiveRecord::Migration
  def change
    remove_column :core_sureties, :organization_id
  end
end
