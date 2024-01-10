# This migration comes from core (originally 20230623182717)
class RemoveActiveLegacyFromCoreNotices < ActiveRecord::Migration[5.2]
  def change
    remove_column :core_notices, :active_legacy, :integer
  end
end
