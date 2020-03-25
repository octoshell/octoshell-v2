# This migration comes from core (originally 20181218072803)
class CreateCoreNotices < ActiveRecord::Migration[4.2]
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
