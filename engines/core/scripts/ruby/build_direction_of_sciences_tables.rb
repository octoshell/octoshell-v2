# require 'rubygems'
# require 'write_xlsx'
# workbook = WriteXLSX.new("Copies.xlsx")
# ['Живые системы,Индустрия наносистем и материалы',
#  'Индустрия наносистем и материалы,Информационно-телекоммуникационные системы'].each do |name|
#    worksheet = workbook.add_worksheet(name[0..30])
#    worksheet.write(0, 0, 'ID')
#    worksheet.write(0, 1, 'Название проекта')
#    name.split(',').each_with_index do |title, title_index|
#      worksheet.write(0, title_index + 2, title)
#    end
#    dir = Core::DirectionOfScience.find_by_name! name
#    dir.projects.includes(:direction_of_sciences).each_with_index do |project, index|
#      offset = index + 1
#      worksheet.write(offset, 0, project.id)
#      worksheet.write(offset, 1, project.title)
#      name.split(',').each_with_index do |title, title_index|
#       worksheet.write(offset, title_index + 2, "a") if project.direction_of_sciences.map(&:name).include? title
#      end
#      (project.direction_of_sciences.to_a - [dir]).each_with_index do |direction, dir_index|
#        worksheet.write(offset, 4 + dir_index, direction.name)
#      end
#    end
# end
# workbook.close
