# This migration comes from core (originally 20150617110105)
class CreateCoreProjectInvitations < ActiveRecord::Migration
  def change
    create_table :core_project_invitations do |t|
      t.integer :project_id, null: false
      t.string :user_fio, null: false
      t.string :user_email, null: false
      t.timestamps

      t.index :project_id
    end
  end
end
