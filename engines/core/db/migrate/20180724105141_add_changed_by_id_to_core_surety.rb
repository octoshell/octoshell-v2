class AddChangedByIdToCoreSurety < ActiveRecord::Migration
  def change
    add_column :core_sureties, :changed_by_id, :integer
    add_index :core_sureties, :changed_by_id
  end
end
