class AddLanguageToCoreInvitations < ActiveRecord::Migration
  def change
    add_column :core_project_invitations, :language, :string,default: 'ru'
  end
end
