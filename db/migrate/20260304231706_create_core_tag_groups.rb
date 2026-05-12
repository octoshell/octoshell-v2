class CreateCoreTagGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :core_tag_groups, if_not_exists: true do |t|
      t.string  :key, null: false
      t.string  :name, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :is_active, null: false, default: true
      t.timestamps null: false
    end

    add_index :core_tag_groups, :key, unique: true, if_not_exists: true
    add_index :core_tag_groups, [:is_active, :sort_order],
              name: "index_core_tag_groups_on_active_and_sort",
              if_not_exists: true
  end
end