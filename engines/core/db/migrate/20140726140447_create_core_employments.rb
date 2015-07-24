class CreateCoreEmployments < ActiveRecord::Migration
  def change
    create_table :core_employments do |t|
      t.integer :user_id
      t.integer :organization_id
      t.boolean :primary
      t.string :state

      t.timestamps
    end
  end
end
