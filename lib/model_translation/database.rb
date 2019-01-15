require 'csv'
module ModelTranslation
  class Database
    attr_reader :workbook
    class << self


      def load_with_sql(relation, rows, output)
        database = Database.new output
        table = relation.table_name
        rows.each do |row|
          fixed_row = row.gsub(/\s/, '')
          records_array = relation.uniq.pluck(fixed_row)
          database.add_sheet(table, row, records_array)
        end
        database.workbook.close
      end

      def load_csv(input, output)
        csv = CSV.read(input).drop 1
        database = Database.new output
        csv.each do |rows|
          table = rows.delete_at 0
          rows.each do |row|
            fixed_row = row.gsub(/\s/, '')
            sql = "Select DISTINCT #{fixed_row}  from  #{table}"
            records_array = ActiveRecord::Base.connection.execute(sql).to_a.map{ |r| r.values.first  }
            database.add_sheet(table, row, records_array)
          end
        end
        database.workbook.close
      end

      def save_data!(input)
        ActiveRecord::Base.transaction do
          Support::Notificator.new.topic
          Support::Topic.find_or_create_by!(name_ru: I18n.t('core.notificators.check.topic'))
          Support::Topic.find_or_create_by!(name_ru: I18n.t('pack.notificators.notify_about_expiring_versions.topic'))

          spreadsheet = Roo::Spreadsheet.open(input)
          spreadsheet.each_with_pagename do |_name, sheet|
            table = sheet.cell('D', 1)
            ru_column = sheet.cell('A', 2)
            if ru_column.split('_').last != 'ru'
              ru_column = "#{ru_column}_ru"
            end
            en_column = sheet.cell('B', 2)
            puts "Processing #{table}.#{ru_column}"
            sheet.to_a.drop(2).each do |row|
              ru_content, en_content = *row
              ru_content = ru_content.gsub(/\\/, '\&\&').gsub(/'/, "''")
              en_content = en_content.gsub(/\\/, '\&\&').gsub(/'/, "''")

              check_sql = "SELECT count(id) from #{table} WHERE #{ru_column} = '#{ru_content}'"
              count = ActiveRecord::Base.connection.execute(check_sql)[0]['count']
              raise "NO records found #{check_sql}" if count.to_i.zero?
              update_sql = %(UPDATE #{table}
              SET #{en_column} = '#{en_content}'
              WHERE #{ru_column} = '#{ru_content}')
              ActiveRecord::Base.connection.execute(update_sql)

            end
          end
        end
      end

    end

    def initialize(table)
      @workbook = WriteXLSX.new(table)
      @counter = 0
    end

    def add_sheet(table, row, records_array)
      worksheet = workbook.add_worksheet "#{@counter}_#{table}.#{row}"[0..30]
      @counter += 1
      worksheet.write(0, 0, 'Model name = ')
      worksheet.write(0, 2, 'table name = ')
      worksheet.write(0, 3, table)

      worksheet.write(1, 0, row)
      worksheet.write(1, 1, "#{row}_en")
      counter = 2
      records_array.each do |r|
        worksheet.write(counter, 0, r)
        counter += 1
      end
    end
  end
end
