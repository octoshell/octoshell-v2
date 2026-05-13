# This migration comes from core (originally 20260513182613)
class CreateCoreSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :core_snapshots, if_not_exists: true do |t|
      t.references :cluster, null: false, foreign_key: { to_table: :core_clusters }, index: true
      t.datetime :captured_at, null: false
    end
  end
end
