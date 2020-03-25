# This migration comes from core (originally 20141113074821)
class TemporaryDropClustersPublicKeyNotNullConstraint < ActiveRecord::Migration[4.2]
  def change
    change_column_null :core_clusters, :public_key, true
    change_column_null :core_clusters, :private_key, true
    change_column_null :core_clusters, :admin_login, true
  end
end
