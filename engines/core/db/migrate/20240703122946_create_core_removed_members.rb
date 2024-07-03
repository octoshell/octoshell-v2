class CreateCoreRemovedMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :core_removed_members do |t|
      t.belongs_to :project
      t.belongs_to :user
      t.string :login
      t.timestamps
    end
  end
end
