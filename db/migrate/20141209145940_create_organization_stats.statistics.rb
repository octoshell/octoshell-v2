# This migration comes from statistics (originally 20141209133252)
class CreateOrganizationStats < ActiveRecord::Migration
  def change
    create_table :statistics_organization_stats do |t|
      t.string :kind
      t.text :data
      t.timestamps
    end
  end
end
