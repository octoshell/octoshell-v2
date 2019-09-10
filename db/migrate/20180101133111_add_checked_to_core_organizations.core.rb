# This migration comes from core (originally 20180101132141)
class AddCheckedToCoreOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :core_organizations, :checked, :boolean,default: false
  end
end
