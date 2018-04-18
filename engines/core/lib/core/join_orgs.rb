module Core
  module JoinOrgs
    def self.load_test_environment
      # create projects prerequisites
      country = Core::Country.create!(title_en: 'Russia', title_ru: 'Россия')
      Core::City.create!(title_en: 'Moscow', title_ru: "Москва", country: country)
      Core::Cluster.create!(host: 'localhost', admin_login: 'octo', name: 'test')
      Core::OrganizationKind.create!(name: 'Российская коммерческая организация')
      Core::CriticalTechnology.create!(name: 'Робототехника')
      Core::DirectionOfScience.create!(name: 'Информационно-телекоммуникационные системы')
      Core::ResearchArea.create!(name: 'Математика')
      Core::ProjectKind.create!(name: 'Исследовательский')
    end

    def self.inspect_table(table_path)
      table = Roo::Spreadsheet.open(table_path)
      rows = table.sheet(0).to_a
      rows.each do |row|
        puts row.inspect
      end
    end

    def self.load_test_data(table_path, environment = :test)
      if environment == :test
        load_test_environment
      end
      city = Core::City.find_by! title_en: 'Moscow'
      country = city.country
      kind = Core::OrganizationKind.first
      table = Roo::Spreadsheet.open(table_path)
      sheet = table.sheet(0).to_a
      sheet.delete_at(0)
      sheet.each do |row|
        id = row[0]
        name = row[1]
        Core::Organization.find_or_create_by(id: id) do |org|
          org.id = id
          org.name = name
          org.city = city
          org.country = country
          org.kind = kind
        end
      end
      sheet.each do |row|
        id = row[4]
        name = row[6] ? row[6] : "name_#{id}"
        next unless id
        Core::Organization.find_or_create_by(id: id) do |org|
          org.id = id
          org.name = name
          org.city = city
          org.country = country
          org.kind = kind
        end
      end


      sheet.each do |row|
        id = row[2]
        name = row[3] ? row[3] : "dep_#{id}"
        org_id = row[0]
        next unless id
        Core::OrganizationDepartment.find_or_create_by(id: id) do |d|
          d.id = id
          d.organization_id = org_id
          d.name = name
        end
      end
      sheet.each do |row|
        id = row[5]
        name = row[7] ? row[7] : "dep_#{id}"
        org_id = row[4]
        next unless id
        Core::OrganizationDepartment.find_or_create_by(id: id) do |d|
          d.id = id
          d.organization_id = org_id
          d.name = name
        end
      end
    end

    def self.merge_from_table(table_path)
      table = Roo::Spreadsheet.open(table_path)
      rows = table.sheet(0).to_a
      rows.delete_at(0)
      ActiveRecord::Base.transaction do
        rows.each do |row|
          # next if row[5] == '!!!!!!!!' || row[5] == '?'
          join_row = JoinRow.new row
          join_row.apply_method
        end
      end
    end
  end
end
