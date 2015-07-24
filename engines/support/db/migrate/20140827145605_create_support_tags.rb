class CreateSupportTags < ActiveRecord::Migration
  def change
    create_table :support_tags do |t|
      t.string :name
      t.timestamps
    end
  end
end
