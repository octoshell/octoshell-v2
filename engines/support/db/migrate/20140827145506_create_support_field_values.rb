class CreateSupportFieldValues < ActiveRecord::Migration
  def change
    create_table :support_field_values do |t|
      t.integer :field_id
      t.integer :ticket_id
      t.text :value

      t.timestamps

      t.index :ticket_id
    end
  end
end
