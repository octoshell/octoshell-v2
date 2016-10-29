# This migration comes from core (originally 20140822104636)
class CreateCoreSuretyScans < ActiveRecord::Migration
  def change
    create_table :core_surety_scans do |t|
      t.integer :surety_id
      t.string :image

      t.index :surety_id
    end
  end
end
