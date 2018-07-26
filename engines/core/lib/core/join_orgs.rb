require 'rubygems'
require 'write_xlsx'
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
      # ActiveRecord::Base.transaction do
        rows.each do |row|
          # next if row[5] == '!!!!!!!!' || row[5] == '?'
          join_row = JoinRow.new row
          join_row.apply_method
        end
      # end
    end

    def self.mergeable_organizations(table_path)
      table = Roo::Spreadsheet.open(table_path)
      rows = table.sheet(0).to_a
      header = rows.delete_at(0)
      grouped_rows = rows.group_by { |row| row[0] }
      grouped_rows.delete_if do |_k, v|
        v.find do |row|
          org_id, org_name, dep_id, dep_name,
          rep_org_id, rep_dep_id, rep_org_name, rep_dep_name = *row
          dep_id.nil?
        end
      end
      grouped_rows.delete_if do |_k, v|
        v.all? do |row|
          org_id, org_name, dep_id, dep_name,
          rep_org_id, rep_dep_id, rep_org_name, rep_dep_name = *row
          rep_org_id.nil? || rep_org_id == 'x' && (rep_dep_id.nil? || rep_dep_id == 'x')
        end
      end

      # отличаются в организации назначения
      grouped_rows.delete_if do |_k, v|
        !v.all? { |e| e[4] == v[0][4]  }
      end

      grouped_rows.each_value do |v|
        unless v.all? { |e| e[4] == v[0][4]  }
          v.each do |e|
            puts "#{e[4].inspect} #{e.inspect}"
          end
          puts "\n\n\n"
        end
      end
      puts grouped_rows.keys.count
      [grouped_rows, header]
    end

    def self.create_table(grouped_rows,header)
      workbook = WriteXLSX.new("merge_pure_orgs.xlsx")
      worksheet = workbook.add_worksheet('first')
      i = 0
      header[6] = 'В какую организацию'
      header[7] = 'В какое подразделение'
      header.each do |h|
        worksheet.write(0, i, h)
        i+= 1
      end
      employments_index = i + 1
      %w[СЛИТЬ? employments sureties_members core_members projects].each do |s|
        worksheet.write(0, i, s)
        i += 1
      end
      grouped_rows.each_with_index do |(key,value), index|
        row_number = index + 1
        first_row = value.first
        worksheet.write(row_number, 0, key)
        worksheet.write(row_number, 1, first_row[1])
        worksheet.write(row_number, 4, first_row[4])
        worksheet.write(row_number, 5, first_row[5])
        worksheet.write(row_number, 6, Core::Organization.find(first_row[4])) if  first_row[4].is_a?(Integer)
        worksheet.write(row_number, 7, Core::OrganizationDepartment.find(first_row[5])) if first_row[5].is_a?(Integer)
        universal_where = "organization_id = #{key} AND organization_department_id IS NULL"
        i = employments_index
        [Core::Employment, Core::SuretyMember, Core::Member, Core::Project].each do |model|
          count = model.where(universal_where).count
          worksheet.write(row_number, i, count)
          i += 1
        end
      end
      workbook.close
    end
  end
end
