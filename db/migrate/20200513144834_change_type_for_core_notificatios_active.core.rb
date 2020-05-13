# This migration comes from core (originally 20200409090425)
class ChangeTypeForCoreNotificatiosActive < ActiveRecord::Migration[5.2]
  def change
    change_column :core_notifications, :active, :integer 
  end
end
