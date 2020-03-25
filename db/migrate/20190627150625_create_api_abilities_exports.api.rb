# This migration comes from api (originally 20190627150437)
class CreateApiAbilitiesExports < ActiveRecord::Migration[4.2]
  def change
    create_table :api_abilities_exports do |t|
      t.belongs_to :ability
      t.belongs_to :export

    end
  end
end
