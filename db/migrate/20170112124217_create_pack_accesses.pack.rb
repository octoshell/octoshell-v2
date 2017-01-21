# This migration comes from pack (originally 20170112121436)
class CreatePackAccesses < ActiveRecord::Migration
  def change
    create_table :pack_accesses do |t|
      t.belongs_to :version,index: true
      t.references :who,polymorphic: true,index: true 
      t.integer :status, :user_id
      t.text :admin_answer,:end_date,:request_text

      t.timestamps 
    end
  end
end
