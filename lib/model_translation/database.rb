require 'csv'
module ModelTranslation
  class Database
    attr_reader :workbook
    class << self
      def load_csv(file = 'to_translate.csv')
        csv = CSV.read(file).drop 1
        database = Database.new 'to_translate_data_unique.xlsx'
        csv.each do |rows|
          table = rows.delete_at 0
          rows.each do |row|
            fixed_row = row.gsub(/\s/, '')
            sql = "Select DISTINCT #{fixed_row}  from  #{table} where #{fixed_row}_en IS NULL"
            records_array = ActiveRecord::Base.connection.execute(sql).to_a.map{ |r| r.values.first  }
            database.add_sheet(table, row, records_array)
          end
        end
        database.workbook.close
      end
    end

    def initialize(table = 'to_translate_data.xlsx')
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
