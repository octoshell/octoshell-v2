class AddCheckedToCoreOrganizations < ActiveRecord::Migration
  def change
    add_column :core_organizations, :checked, :boolean,default: false
  end
end
