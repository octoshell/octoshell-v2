# This migration comes from authentication (originally 20140312063728)
class SorceryCore < ActiveRecord::Migration
  def change
    create_table :authentication_users do |t|
      t.string :email,            :null => false
      t.string :crypted_password, :null => false
      t.string :salt,             :null => false

      t.timestamps
    end

    add_index :authentication_users, :email, unique: true
  end
end
