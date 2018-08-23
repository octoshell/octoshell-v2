namespace :translation do
  task :generate_migration_input => :environment do
    locales = I18n.available_locales - [:ru]
    rows = CSV.read('to_translate.csv').drop 1
    rows.each do |row|
      table_name = row.delete_at(0)
      row.each do |r|
        normalized_column = r.gsub(/\s+/,'')
        puts %(rename_column :#{table_name}, :#{normalized_column}, :#{normalized_column}_#{I18n.default_locale})
        locales.each do |locale|
          puts %(add_column :#{table_name}, :#{normalized_column}_#{locale}, :string)
        end
      end
      row.first
    end
  end

  task :load, [:table] => :environment do |t, args|
    ModelTranslation::Database.load_csv(args[:table])
  end

  task :save_data, [:table] => :environment do |t, args|
    ModelTranslation::Database.save_data!(args[:table])
  end


  task :load_with_sql => :environment do
    relation = Sessions::SurveyField.joins(survey: :session)
                                    .where(sessions_sessions: {description_ru: 2018})

    ModelTranslation::Database.load_with_sql(relation, ['hint_ru','name_ru'], 'sessions.xlsx')
  end


end
