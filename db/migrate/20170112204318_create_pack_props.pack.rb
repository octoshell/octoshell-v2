# This migration comes from pack (originally 20170112203757)
class CreatePackProps < ActiveRecord::Migration
  def change
    create_table :pack_props do |t|
      t.belongs_to :user,index: true
      t.integer :proj_or_user
      t.timestamps 
    end
  end
end
