# This migration comes from core (originally 20180830083345)
class AddLanguageToCoreInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :core_project_invitations, :language, :string,default: 'ru'
  end
end
