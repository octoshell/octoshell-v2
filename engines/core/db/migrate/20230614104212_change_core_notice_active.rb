class ChangeCoreNoticeActive < ActiveRecord::Migration[5.2]
  def change
    rename_column :core_notices, :active, :active_legacy
    add_column :core_notices, :active, :boolean, default: false
  end
end
