# This migration comes from core (originally 20141113105108)
class CreateCoreQuotaKinds < ActiveRecord::Migration
  def change
    create_table :core_quota_kinds do |t|
      t.string :name
      t.string :measurement
    end
  end
end
