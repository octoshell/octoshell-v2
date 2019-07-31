# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
ActiveRecord::Base.transaction do

  ActiveRecord::Base.connection.tables.each do |table|
    next if table == 'schema_migrations'
    ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
  end


  puts 'Running seeds'
  Group.default!
  # users = []
  # 3.times do |i|
  #   user = User.create!(email: "user_#{i.next}@octoshell.ru",
  #                       password: "123456", password_confirmation: '123456',
  #                       access_state: 'active')
  #   p=user.profile
  #   p.first_name = "User_#{i}"
  #   p.middle_name = "Jr."
  #   p.last_name = "Tester"
  #   user.activate!
  #   user.save!
  #   users << user
  # end
  #

  users = 3.times.map do
    FactoryBot.create(:user)
  end
  admin = FactoryBot.create(:admin, email: 'admin@octoshell.ru')

  country = Core::Country.create!(title_en: 'Russia', title_ru: 'Россия', checked: true)
  city = Core::City.create!(title_en: 'Moscow', title_ru: "Москва", country: country, checked: true)

  Core::Cluster.create!(host: 'localhost', admin_login: 'octo', name: 'test', description: 'mytest')

   Core::QuotaKind.create!([{ name_ru: "CPU", measurement_ru: "часов", name_en: "CPU", measurement_en: "hours"},
   { name_ru: "GPU", measurement_ru: "часов", name_en: "GPU", measurement_en: "hours"},
   { name_ru: "Место на HDD", measurement_ru: "Гб", name_en: "HDD space", measurement_en: "Gb"}])
   Core::Cluster.all.each do |cluster|
     Core::Partition.create!(name: 'main_part', cluster: cluster, resources: 'nodes:128,cores:8,gppus:1')
     Core::QuotaKind.all.each do |kind|
       cluster.quotas.create!(quota_kind: kind, value: 200)
     end
   end
  #
  Core::OrganizationKind.create!(name: 'Российская коммерческая организация')
  Core::CriticalTechnology.create!(name: 'Робототехника')
  Core::DirectionOfScience.create!(name: 'Информационно-телекоммуникационные системы')
  Core::ResearchArea.create!(name: 'Математика')
  Core::ProjectKind.create!(name: 'Исследовательский')
  organization = Core::Organization.create!(name: 'Test MSU', city: city, country: country,
                                            kind: Core::OrganizationKind.first, checked: true )
  users.each do |user|
    Core::Employment.create!(user: user, organization: Core::Organization.first)
  end
  project = FactoryBot.create(:project, owner: users.first)
  project.member_owner.update!(project_access_state: 'allowed')

  User.all.each do |user|
    Core::Credential.create!(user: user, name: 'example key',
                             public_key: SSHKey.generate(:comment => user.email).ssh_public_key)
  end

  users[1..-1].each do |user|
    project.members.create!(user: user, organization: organization, project_access_state: 'allowed')
  end








  Comments.create_wiki_page
  Comments.create_abilities

end
