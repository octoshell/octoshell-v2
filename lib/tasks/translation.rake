namespace :translation do
  task :generate_migration_input => :environment do
    locales = I18n.available_locales - [:ru]
    rows = CSV.read('to_translate.csv').drop 1
    rows.each do |row|
      table_name = row.delete_at(0)
      row.each do |r|
        locales.each do |locale|
          puts %(add_column :#{table_name}, :#{r}_#{locale}, :string)
        end
      end
      row.first
    end
  end

  task :load => :environment do
    ModelTranslation::Database.load_csv
  end

end
