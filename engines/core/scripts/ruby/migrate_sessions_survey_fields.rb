puts "Rebuilding survey fields collections"
array = [[["Экспертиза отчетов пользователей СКЦ МГУ в предметной области (если «да», то уточните, пожалуйста, в какой именно)",
   "Reports examination of users of the MSU HPC center in the subject area (if \"yes\", please specify which one)"],
  ["Установка, настройка и тестирование прикладных пакетов (если «да», то уточните пожалуйста, каких именно)",
   "Installation, configuration and testing of application packages (if \"yes\", please specify which ones)"]],
 [["MPI", ""],
  ["C/C++", ""],
  ["Fortran", ""],
  ["OpenMP", ""],
  ["CUDA", ""],
  ["Прикладные пакеты", "Application packages"],
  ["OpenCL", ""],
  ["OpenACC", ""],
  ["Intel Compiler", ""],
  ["GNU Compiler", ""],
  ["PGI Compiler", ""]],
 [["Принципиально важна высокая точность вещественной арифметики - 64 разряда", "Essentially important is the high accuracy of real arithmetic - 64 bits"],
  ["Вещественная арифметика используется, но достаточно 32 разрядов", "Real arithmetic is used, but 32 bits are enough"],
  ["Вещественная арифметика активно не используется", "Real arithmetic is not actively used"],
  ["Не задумывался над этим", "I did not think about it"]],
 [["Технология MPI", "MPI technology"],
  ["Технология OpenMP", "OpenMP technology"],
  ["Технологии программирования графических процессоров", "Programming technologies of graphics processors"],
  ["Введение в параллельные методы решения задач", "Introduction to parallel methods for solving problems"],
  ["Оптимизация и повышение эффективности параллельных приложений", "Optimization and increasing the efficiency of parallel applications"],
  ["Отладка параллельных приложений", "Debugging parallel applications"],
  ["Работа с конкретным пакетом или инструментарием (укажите, с каким, пожалуйста)", "Work with a specific package or toolkit (please specify which one)"]],
 [["Используются только классические многоядерные процессоры (разделы с процессорами Intel)", "Only classic multi-core processors are used (partitions with Intel processors)"],
  ["Используются графические ускорители (разделы с процессорами NVIDIA )", "Graphics accelerators (partitions with NVIDIA processors) are used"],
  ["Используются и многоядерные процессоры, и графические ускорители ", "Multi-core processors and graphics accelerators are used"],
  ["Для меня не важно: где установлен пакет, там и работаю", "It does not matter for me: where the package is installed, I work there"]],
 [["Подтверждаю", "I confirm"]],
 [["да, узлы с процессорами Intel", "yes, nodes with Intel processors"], ["да, узлы с процессорами NVIDIA", "yes, nodes with NVIDIA processors"]],
 [["Международные (за рубежом)\t", "International (abroad)"], ["Международные (в России)\t", "International (in Russia)"], ["Российские\t", "Russian"]],
 [["Международные (за рубежом)\t", "International (abroad)"], ["Международные (в России)\t", "International (in Russia)"], ["Российские", "Russian"]],
 # [["Международные (за рубежом)\t", ""], ["Международные (в России)\t", ""], ["Российские", ""]],
 [["студенты", "students"], ["аспиранты", "postgraduates"]],
 [["Да", "Yes"], ["Нет", "No"]],
 [["РФФИ", "RFBR"],
  ["РНФ", "Russian Science Foundation"],
  ["Минобрнауки РФ", "The Ministry of Education and Science of Russia"],
  ["Минкомсвязи РФ", "The Ministry of Digital Development, Communications and Mass Media of Russia"],
  ["Минобороны РФ", "The Ministry of Defence of Russia"],
  ["Минпромторг РФ", "The Ministry of industry and trade of Russia"],
  ["Программы РАН", "RAS programms"],
  ["Роснано", "Rusnano"],
  ["ФПИ", "Russian Foundation for Advanced Research Projects"],
  ["Финансирование от иного российского источника", "Funding from another Russian source"],
  ["Финансирование от иного зарубежного источника", "Funding from another foreign source"]],
 [["Число опубликованных статей по проекту за 2017 год ", "Number of published articles on the project in 2017"], ["Число учебников и монографий", "Number of textbooks and monographs"], ["Число тезисов докладов", "Number of messages of reports"]]]

def records(elem)
  collection = elem.map(&:first).join("\r\n")
  rel = Sessions::SurveyField.where(collection: collection)
  raise "not found" unless rel.exists?
  rel
end

def updated_collection(elem)
  elem.map{ |l|  l.second.present? ? l.join("|").gsub("\t","") : l.first }.join("\r\n")
end


ActiveRecord::Base.transaction do
  array.each do |elem|
    relation = records(elem)
    relation.each do |field|
      field.update!(collection: updated_collection(elem))
    end
  end
end
