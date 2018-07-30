class CreateCommentsGroupClasses < ActiveRecord::Migration
  def change
    create_table :comments_group_classes do |t|
      t.string :class_name
      t.integer :obj_id, default: :null
      t.belongs_to :group, index: true
      t.boolean :allow, null: false
      t.integer :type_ab, null: false
      t.timestamps null: false
    end
  end
end
