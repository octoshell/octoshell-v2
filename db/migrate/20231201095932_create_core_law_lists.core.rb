# This migration comes from core (originally 20231201095649)
class CreateCoreLawLists < ActiveRecord::Migration[5.2]
  def change
    create_table :core_law_lists do |t|

      t.timestamps
    end
  end
end
