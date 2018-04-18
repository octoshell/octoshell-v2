class CreateCommentsContextGroups < ActiveRecord::Migration
  def change
    create_table :comments_context_groups do |t|
      t.belongs_to :context, null: false, index: true
      t.belongs_to :group, null: false, index: true
      t.integer :type_ab, null: false
      t.timestamps null: false
    end
  end
end
