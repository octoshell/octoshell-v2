# This migration comes from core (originally 20251221195911)
class CreateCoreResourceUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :core_resource_users do |t|
      t.string :email
      t.belongs_to :access
      t.belongs_to :user
    end
  end
end
