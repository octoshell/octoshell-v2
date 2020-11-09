# This migration comes from cloud_computing (originally 20201107153714)
class CreateCloudComputingClusters < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_clusters do |t|
      t.belongs_to :core_cluster
      t.text :description_ru
      t.text :description_en
      t.timestamps
    end
  end
end
