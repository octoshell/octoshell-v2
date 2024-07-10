class CreateCoreLawLists < ActiveRecord::Migration[5.2]
  def change
    create_table :core_law_lists do |t|

      t.timestamps
    end
  end
end
