# This migration comes from jobstat (originally 20171226062007)
class CreateJobstatDataTypes < ActiveRecord::Migration
  def change
    return
    create_table :jobstat_data_types do |t|
      t.string :name, :index => true
      t.string :type, :limit => 1

      t.timestamps null: false
    end
  end
end
