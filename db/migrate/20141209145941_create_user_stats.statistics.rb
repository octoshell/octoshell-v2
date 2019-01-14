# This migration comes from statistics (originally 20141209133315)
class CreateUserStats < ActiveRecord::Migration
  def change
    create_table :statistics_user_stats do |t|
      t.string :kind
      t.text :data
      t.timestamps
    end
  end
end
