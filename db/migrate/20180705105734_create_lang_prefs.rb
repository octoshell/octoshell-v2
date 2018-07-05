class CreateLangPrefs < ActiveRecord::Migration
  def change
    create_table :lang_prefs do |t|
      t.string :language
      t.belongs_to :user, index: true, null: false
      t.timestamps
    end
  end
end
