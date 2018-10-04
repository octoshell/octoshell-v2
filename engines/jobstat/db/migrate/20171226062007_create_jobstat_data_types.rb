class CreateJobstatDataTypes < ActiveRecord::Migration
  def change
    return true
    create_table :jobstat_data_types do |t|
      t.string :name, :index => true
      t.string :type, :limit => 1

      t.timestamps null: false
    end
  end
end
