# This migration comes from core (originally 20191028224329)
class CreateCoreBotLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :core_bot_links do |t|
      t.belongs_to :user, foreign_key: true
      t.string :token
      t.boolean :active

      t.timestamps
    end
  end
end
