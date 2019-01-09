# This migration comes from core (originally 20141119153702)
class AddIndexOnOwnerFieldInCoreMembers < ActiveRecord::Migration
  def change
    add_index :core_members, [:user_id, :owner]
  end
end
