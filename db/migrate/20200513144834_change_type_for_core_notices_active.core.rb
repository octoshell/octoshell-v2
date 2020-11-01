# This migration comes from core (originally 20200409090425)
class ChangeTypeForCoreNoticesActive < ActiveRecord::Migration[5.2]
  def change
    remove_column :core_notices, :active, :boolean
    add_column :core_notices, :active, :integer
  end
end
