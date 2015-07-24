class CreateAbilities < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.string :action
      t.string :subject
      t.integer :group_id
      t.boolean :available, default: false

      t.timestamps
      t.index :group_id
    end
  end
end
