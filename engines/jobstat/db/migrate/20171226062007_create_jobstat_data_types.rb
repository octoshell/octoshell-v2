class CreateJobstatDataTypes < ActiveRecord::Migration
  def change
    return if File.exists? '/tmp/skip_bad_migrations.txt'
    create_table :jobstat_data_types do |t|
      t.string :name, :index => true
      t.string :type, :limit => 1

      t.timestamps null: false
    end
  end
end
