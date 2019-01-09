class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :weight
      t.boolean :system

      t.timestamps
    end

    create_table :user_groups do |t|
      t.integer :user_id
      t.integer :group_id

      t.index :user_id
      t.index :group_id
    end
  end
end
