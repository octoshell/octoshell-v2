class CreateApiAbilitiesExports < ActiveRecord::Migration
  def change
    create_table :api_abilities_exports do |t|
      t.belongs_to :ability
      t.belongs_to :export

    end
  end
end
