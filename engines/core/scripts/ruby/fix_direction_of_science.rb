def merge_with_name(source_name, to_name)
  to = ::Core::DirectionOfScience.find_by!(name: to_name)
  source = Core::DirectionOfScience.find_by!(name: source_name)
  source.projects.each do |project|
    project.direction_of_sciences.delete source
    project.direction_of_sciences << to unless project.direction_of_sciences.include? to
    project.save!(validate: false)
  end
  source.destroy
end

def merge_with_names(source_name, to_name1, to_name2)
  to1 = ::Core::DirectionOfScience.find_by!(name: to_name1)
  to2 = ::Core::DirectionOfScience.find_by!(name: to_name2)
  source = Core::DirectionOfScience.find_by!(name: source_name)
  source.projects.each do |project|
    project.direction_of_sciences.delete source
    project.direction_of_sciences << to1 unless project.direction_of_sciences.include? to1
    project.direction_of_sciences << to2 unless project.direction_of_sciences.include? to2
    project.save!(validate: false)
  end
  source.destroy
end



# Индустрия наносистем влить в Индустрия наносистем и материалы
#
#     Перспективные виды вооружения, военной и специальной техники и Перспективные вооружения, военная и специальная техника одно и то же
#
#     Транспортные и космические системы влить в Транспортные, авиационные и космические системы
#
# Три похожих направления:
#     :Энергетика и энергосбережение
#     :Энергетика, энергосбережение, ядерная энергетика
#     :Энергоэффективность, энергосбережение, ядерная энергетика
#     Создать новую запись "Энергетика" и влить все туда
#
# Живые системы,Индустрия наносистем и материалы разделить
# Индустрия наносистем и материалы,Информационно-телекоммуникационные системы разделить(12,11)

ActiveRecord::Base.transaction do
  ['Живые системы,Индустрия наносистем и материалы',
   'Индустрия наносистем и материалы,Информационно-телекоммуникационные системы'].each do |name|
     args = [name] + name.split(',')
     merge_with_names(*args)
   end
  merge_with_name("Индустрия наносистем и материалы", "Индустрия наносистем")
  merge_with_name("Перспективные вооружения, военная и специальная техника","Перспективные виды вооружения, военной и специальной техники")
  merge_with_name("Транспортные, авиационные и космические системы","Транспортные и космические системы")
  merge_with_name("Энергетика и энергосбережение","Энергоэффективность, энергосбережение, ядерная энергетика")
  merge_with_name("Энергетика, энергосбережение, ядерная энергетика","Энергоэффективность, энергосбережение, ядерная энергетика")
  merge_with_name("Живые системы","Науки о жизни")
  puts Core::DirectionOfScience.all.to_a.map(&:name).inspect
  puts Core::DirectionOfScience.count
end
