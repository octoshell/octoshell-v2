class ReplaceUserWithMemberInResourceUsers < ActiveRecord::Migration[5.2]
  def up
    # Add member_id column
    add_column :core_resource_users, :member_id, :integer
    add_foreign_key :core_resource_users, :core_members, column: :member_id

    # Remove user_id foreign key and column
    remove_foreign_key :core_resource_users, :users
    remove_column :core_resource_users, :user_id

    # Add unique index on member_id and access_id (if member_id present)
    add_index :core_resource_users, %i[member_id access_id], unique: true, where: 'member_id IS NOT NULL'
    # Remove old unique index on user_id and access_id
    remove_index :core_resource_users, %i[user_id access_id] if index_exists?(:core_resource_users,
                                                                              %i[user_id access_id])
  end

  def down
    # Re-add user_id column
    add_column :core_resource_users, :user_id, :integer
    add_foreign_key :core_resource_users, :users

    # Remove member_id
    remove_foreign_key :core_resource_users, :core_members
    remove_column :core_resource_users, :member_id

    # Restore old index
    add_index :core_resource_users, %i[user_id access_id], unique: true
    remove_index :core_resource_users, %i[member_id access_id] if index_exists?(:core_resource_users,
                                                                                %i[member_id access_id])
  end
end
