class CreateCoreResourceUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :core_resource_users do |t|
      t.string :email
      t.belongs_to :user
      t.belongs_to :access
    end
  end
end
