# This migration comes from core (originally 20141113105618)
class AddQuotaKindToCoreTables < ActiveRecord::Migration
  def change
    add_column :core_cluster_quotas, :quota_kind_id, :integer
    add_column :core_request_fields, :quota_kind_id, :integer
    add_column :core_access_fields, :quota_kind_id, :integer

    remove_column :core_cluster_quotas, :name, :string
    remove_column :core_request_fields, :name, :string
    remove_column :core_access_fields, :name, :string
  end
end
