namespace :core do
  task :merge, [:table_path] => :environment  do |t,args|
    ActiveRecord::Base.transaction do
      Core::JoinOrgs.merge_from_table(args[:table_path])
      Core::Organization.all.each do |o|
        o.update!(checked: true)
      end
      Core::OrganizationDepartment.all.each do |o|
        o.update!(checked: true)
      end
    end
  end

  task :merge_dif => :environment do
    ActiveRecord::Base.transaction do
      Core::JoinOrgs.merge_from_table("merge_orgs.xlsx")
      Core::JoinOrgs.merge_from_table("joining-orgs_2017_11-2.ods")
      Core::Organization.all.each do |o|
        o.update!(checked: true)
      end
      Core::OrganizationDepartment.all.each do |o|
        o.update!(checked: true)
      end
    end
  end

  task :remove_invalid_mergers => :environment  do |t,args|
    table = Roo::Spreadsheet.open("merge_orgs.xlsx")
    table2 = Roo::Spreadsheet.open("joining-orgs_2017_11-2.ods")
    rows = table.sheet(0).to_a.map{ |row| row[0]  }
    rows2 = table2.sheet(0).to_a.map{ |row| row[0]  }

    puts (rows & rows2).inspect
    # rows.each do |row|
    #   linked_rows = rows2.select{ |r| r[0] == row[0] }
    #   unless linked_rows.all?{|l| l[5] == linked_rows[0][5] }
    #     puts row.inspect.red
    #   end
    # end
    # org_id, org_name, dep_id, dep_name,
    # rep_org_id, rep_dep_id, rep_org_name, rep_dep_name = *row
    # rep_org_id.nil? || rep_org_id == 'x' && (rep_dep_id.nil? || rep_dep_id == 'x')

  end

  task :mergeable_organizations, [:table_path] => :environment do |_t, args|

    args = Core::JoinOrgs.mergeable_organizations(args[:table_path])
    Core::JoinOrgs.create_table(*args)
    # puts grouped_rows.inspect
    # filtered_rows = rows.select map do |row|
    #
    # end
    #без x в поле замены подразделения и без x в поле замены организации

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
  # Если у города нет страны, будет  выведена страна,
  # выставленная у организаций с этим городом(если конечно страна у организаций одна)
  task :check_cities => :environment do
    ActiveRecord::Base.transaction do
      Core::City.all.each(&:bad)
      Core::City.all.each(&:check_country)
    end
  end


  task :fix_cities => :environment do
    next if Core::City.where(title_ru: 'Москва').count == 1
    ActiveRecord::Base.transaction do
      actions = {
          5469085 => 88,
          5469083 => [5468993, 'Москва'],
          5469081 => [5468993, 'Москва'],
          5469080 => [5469078, 'Протвино'],
          5469079 => [5469078, 'Протвино'],
          5469077 => ['Peru', 'Перу'],
          5469075 => [5468995, 'Новосибирск'],
          5469074 => [5468993, 'Москва']
      }
      actions.each do |key, value|
        city = Core::City.find(key)
        if value.is_a? Integer
          city.country_id = value
          city.save!
          city.organizations.each do |o|
            o.country = city.country
            o.save!
          end
        elsif value.first.is_a? String
          city.country = Core::Country.create!(title_en: value.first,
                                               title_ru: value.second,
                                               checked: true)
          city.organizations.each do |o|
            o.country = city.country
            o.save!
          end
        else
          new_city = Core::City.find(value.first)
          organizations = city.organizations.to_a
          organizations.each do |o|
            o.city = new_city
            o.country = new_city.country
            o.save!
          end
          city.destroy!
        end
      end
    end
  end

  task :fix_organizations => :environment do
    ActiveRecord::Base.transaction do
      [1188, 1190].each do |id|
        org = Core::Organization.find(id)
        org.update!(city: Core::City.find_by!(title_ru: 'Протвино'))
      end
      [1016, 1017, 1132, 1188, 1190].each do |id|
        org = Core::Organization.find(id)
        org.update!(country_id: org.city.country_id)
      end

    end
  end

  task :fix_everything => :environment do
    list = %w[check_employments check_projects fix_cities check_cities fix_organizations check_organizations]
    list.each do |elem|
      Rake::Task["core:#{elem}"].invoke
    end
  end
end
