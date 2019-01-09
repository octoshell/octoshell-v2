class CreateCoreCountriesAndCities < ActiveRecord::Migration
  def change
    create_table :core_countries do |t|
      t.string :title_ru
      t.string :title_en
    end

    create_table :core_cities do |t|
      t.integer :country_id
      t.string :title_ru
      t.string :title_en

      t.index :country_id
      t.index :title_ru
    end
  end
end
