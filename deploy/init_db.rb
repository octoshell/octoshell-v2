ActiveRecord::Base.transaction do
Group.default!
Comments.create_wiki_page
Comments.create_abilities
Octoface::OctoConfig.create_abilities!
user = User.create!(email: 'bot@bot.ru', password: 'botbotbot')
user.groups << Group.superadmins
user.update!(activation_state: "active")
Face::MyMenu.init_menu
UserGroup.where(user: user).each(&:destroy!)
user.destroy!

[{"name_ru"=>"Факультет", "name_en"=>"Faculty"},
 {"name_ru"=>"Кафедра", "name_en"=>"Department"},
 {"name_ru"=>"Должность", "name_en"=>"Position"},
 {"name_ru"=>"Должность по РФФИ", "name_en"=>"Position according RFBR list"},
 {"name_ru"=>"Номер группы (для студентов МГУ)",
  "name_en"=>"Group number (only for MSU students)"}].each do |h|
    Core::EmploymentPositionName.create!(h)
  end

name = Core::EmploymentPositionName.find_by_name_ru!('Должность по РФФИ')
[{"name_ru"=>"Академик-секретарь", "name_en"=>"Academician-secretary"},
{"name_ru"=>"Аспирант", "name_en"=>"Graduate student"},
{"name_ru"=>"Ассистент", "name_en"=>"Assistant"},
{"name_ru"=>"Ведущий научный сотрудник", "name_en"=>"Leading Researcher"},
{"name_ru"=>"Ведущий специалист", "name_en"=>"Leading Specialist"},
{"name_ru"=>"Вице-презедент", "name_en"=>"Vice prezedent"},
{"name_ru"=>"Генеральный директор", "name_en"=>"Director General"},
{"name_ru"=>"Генеральный конструктор", "name_en"=>"General designer"},
{"name_ru"=>"Главный научный сотрудник", "name_en"=>"Chief Researcher"},
{"name_ru"=>"Главный редактор", "name_en"=>"Chief Editor"},
{"name_ru"=>"Главный специалист", "name_en"=>"Chief Specialist"},
{"name_ru"=>"Декан", "name_en"=>"Dean"},
{"name_ru"=>"Директор", "name_en"=>"Director"},
{"name_ru"=>"Докторант", "name_en"=>"Doctorant"},
{"name_ru"=>"Доцент", "name_en"=>"Assistant Professor"},
{"name_ru"=>"Заведующий кафедрой", "name_en"=>"Head of the Department"},
{"name_ru"=>"Заведующий станцией", "name_en"=>"Station head"},
{"name_ru"=>"Зам. академика-секретаря",
"name_en"=>"Deputy Academician-secretary"},
{"name_ru"=>"Зам. генерального директора",
"name_en"=>"Deputy Director General"},
{"name_ru"=>"Зам. главного редактора", "name_en"=>"Deputy Chief Editor"},
{"name_ru"=>"Зам. декана", "name_en"=>"Deputy dean"},
{"name_ru"=>"Зам. директора", "name_en"=>"Deputy director"},
{"name_ru"=>"Зам. председателя", "name_en"=>"Deputy chairman"},
{"name_ru"=>"Зам. руководителя", "name_en"=>"Deputy head"},
{"name_ru"=>"Зам. руководителя группы", "name_en"=>"Deputy team leader"},
{"name_ru"=>"Зам. руководителя лаборатории",
"name_en"=>"Deputy head of laboratory"},
{"name_ru"=>"Зам. руководителя отдела",
"name_en"=>"Deputy head of department"},
{"name_ru"=>"Зам. руководителя отделения",
"name_en"=>"Deputy branch manager"},
{"name_ru"=>"Зам. руководителя сектора", "name_en"=>"Deputy sector head"},
{"name_ru"=>"Зам. руководителя центра", "name_en"=>"Deputy center head"},
{"name_ru"=>"Консультант", "name_en"=>"Consultant"},
{"name_ru"=>"Лаборант", "name_en"=>"Assistant"},
{"name_ru"=>"Младший научный сотрудник", "name_en"=>"Junior Researcher"},
{"name_ru"=>"Научный консультант", "name_en"=>"Research Advisor"},
{"name_ru"=>"Научный сотрудник", "name_en"=>"Researcher"},
{"name_ru"=>"Начальник управления", "name_en"=>"Head of Department"},
{"name_ru"=>"Начальник экспедиции", "name_en"=>"Expedition Leader"},
{"name_ru"=>"Председатель", "name_en"=>"Chairman"},
{"name_ru"=>"Президент", "name_en"=>"President"},
{"name_ru"=>"Преподаватель", "name_en"=>"Teacher"},
{"name_ru"=>"Проректор", "name_en"=>"Provost"},
{"name_ru"=>"Профессор", "name_en"=>"Professor"},
{"name_ru"=>"Редактор", "name_en"=>"Editor"},
{"name_ru"=>"Ректор", "name_en"=>"Rector"},
{"name_ru"=>"Руководитель группы", "name_en"=>"Team leader"},
{"name_ru"=>"Руководитель лаборатории", "name_en"=>"Head of laboratory"},
{"name_ru"=>"Руководитель отдела", "name_en"=>"Head of department"},
{"name_ru"=>"Руководитель отделения", "name_en"=>"Director of Department"},
{"name_ru"=>"Руководитель сектора", "name_en"=>"Sector Manager"},
{"name_ru"=>"Руководитель центра", "name_en"=>"Head of the center"},
{"name_ru"=>"Советник", "name_en"=>"Adviser"},
{"name_ru"=>"Специалист", "name_en"=>"Specialist"},
{"name_ru"=>"Старший специалист", "name_en"=>"Senior Specialist"},
{"name_ru"=>"Старший лаборант", "name_en"=>"Senior Assistant"},
{"name_ru"=>"Старший преподаватель", "name_en"=>"Senior Lecturer"},
{"name_ru"=>"Старший техник", "name_en"=>"Senior technician"},
{"name_ru"=>"Стажер", "name_en"=>"Trainee"},
{"name_ru"=>"Старший научный сотрудник", "name_en"=>"Senior Researcher"},
{"name_ru"=>"Студент", "name_en"=>"Student"},
{"name_ru"=>"Техник", "name_en"=>"Technician"},
{"name_ru"=>"Ученый секретарь", "name_en"=>"Scientific Secretary"},
{"name_ru"=>"Другая должность", "name_en"=>"Other position"}].each do |h|
  Core::EmploymentPositionField.create!(h.merge(employment_position_name: name))
end
end
