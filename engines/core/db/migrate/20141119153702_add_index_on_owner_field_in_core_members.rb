class AddIndexOnOwnerFieldInCoreMembers < ActiveRecord::Migration
  def change
    add_index :core_members, [:user_id, :owner]
  end
end
