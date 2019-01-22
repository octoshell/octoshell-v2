class CreateCoreSureties < ActiveRecord::Migration
  def change
    create_table :core_sureties do |t|
      t.integer :project_id
      t.integer :organization_id
      t.string :state
      t.string :scan
      t.string :comment
      t.string :boss_full_name
      t.string :boss_position

      t.timestamps

      t.index :project_id
      t.index :organization_id
    end

    create_table :core_surety_members do |t|
      t.integer :user_id
      t.integer :surety_id

      t.index :user_id
      t.index :surety_id
    end
  end
end
