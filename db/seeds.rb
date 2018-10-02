# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

ActiveRecord::Base.transaction do
  # ActiveRecord::Base.connection.tables.each do |table|
  #   next if table == 'schema_migrations'
  #   ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
  # end
  Group.default!
  users = []
  3.times do |i|
    user = User.create!(email: "user#{i.next}@octoshell.ru",
                        password: "123456", password_confirmation: '123456',
                        access_state: 'active')
    user.activate!
    user.save
    users << user
  end
  admin = User.create!(email: "admin@octoshell.ru",
                       password: "123456", password_confirmation: '123456')
  admin.activate!
  admin.groups << Group.superadmins
  admin.access_state='active'
  admin.save!





  #
  #
  # create projects prerequisites

  country = Core::Country.create!(title_en: 'Russia', title_ru: 'Россия')

  city = Core::City.create!(title_en: 'Moscow', title_ru: "Москва", country: country)

  Core::Cluster.create!(host: 'localhost', admin_login: 'octo', name: 'test')
  Core::Credential.create!(user: admin, name: 'example key', public_key: Core::Cluster.first.public_key)
  Core::OrganizationKind.create!(name: 'Российская коммерческая организация')
  Core::CriticalTechnology.create!(name: 'Робототехника')
  Core::DirectionOfScience.create!(name: 'Информационно-телекоммуникационные системы')
  Core::ResearchArea.create!(name: 'Математика')
  Core::ProjectKind.create!(name: 'Исследовательский')
  Core::Organization.create!(name: 'Test MSU', city: city, country: country,
                             kind: Core::OrganizationKind.first )
  Core::Employment.create!(user: admin, organization: Core::Organization.first)
  rake = Rake.application
  rake.init
  rake.load_rakefile
  rake['comments:create_wiki_page'].invoke
  # rake['comments:recreate_attachable_abilities'].invoke


end
