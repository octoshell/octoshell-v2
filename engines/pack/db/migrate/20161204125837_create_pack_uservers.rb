class CreatePackUservers < ActiveRecord::Migration
  def change
    create_table :pack_uservers do |t|
      t.belongs_to :pack_version, index: true
      t.belongs_to :user, index: true
      t.text :end_lic
      t.timestamps 
    end
  end
end
