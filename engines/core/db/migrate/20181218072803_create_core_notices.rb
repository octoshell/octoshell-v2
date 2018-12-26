class CreateCoreNotices < ActiveRecord::Migration
  def change
    create_table :core_notices do |t|
      t.references :sourceable, polymorphic: true, index: true
      t.references :linkable, polymorphic: true, index: true
      t.text :message
      t.integer :count

      t.timestamps null: false
    end
  end
end
