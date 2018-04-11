namespace :core do
  task :merge, [:table_path] => :environment  do |t,args|
    Core::JoinOrgs.merge_from_table(args[:table_path])
  end

  # Проверяет, что у всех организаций выставлена страна, соответствующая стране города
  task :check_organizations => :environment do
    ActiveRecord::Base.transaction do
      Core::Organization.all.each(&:check_location)
    end
  end

  # Проверяет, что все проекты правильны
  task :check_projects => :environment do
    Core::Project.all.each do |p|
      " #{p.errors.inspect} FAILED" if p.invalid?
    end
  end

  # Удаляет все записи в таблице Employment, где выставлен несуществующий пользователь
  task :check_employments => :environment do
    ActiveRecord::Base.transaction do
      Core::Employment.where("user_id NOT IN (SELECT id FROM users)").each do |e|
        puts "Destroying #{e.inspect}"
        e.destroy
      end
    end
  end

  # Проверяет, что у всех городов существует страна.
  # Таск интерактивен, можно изменять страну находу!
  # Если у города нет страны, будет предложено выбрать страну,
  # выставленную у организаций с этим городом(если конечно страна у организаций одна)
  task :check_cities => :environment do
    ActiveRecord::Base.transaction do
      Core::City.all.each(&:check_country)
    end
  end
end
