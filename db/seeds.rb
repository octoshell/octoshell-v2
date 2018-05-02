# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Group.superadmins
Group.authorized

users = []
3.times do |i|
  user = User.create!(email: "user#{i.next}@octoshell.ru",
                      password: "123456", password_confirmation: '123456')
  user.activate!
  user.activate!
  user.access_state='active'
  user.save
  users << user
end

admin = User.create!(email: "admin@octoshell.ru",
                     password: "123456", password_confirmation: '123456')
admin.activate!
admin.activate!

Group.default!

admin.groups << Group.superadmins
admin.access_state='active'
admin.save!


# create projects prerequisites

country = Core::Country.create!(title_en: 'Russia', title_ru: 'Россия')

Core::City.create!(title_en: 'Moscow', title_ru: "Москва", country: country)

Core::Cluster.create!(host: 'localhost', admin_login: 'octo', name: 'test')

Core::OrganizationKind.create!(name: 'Российская коммерческая организация')
Core::CriticalTechnology.create!(name: 'Робототехника')

Core::DirectionOfScience.create!(name: 'Информационно-телекоммуникационные системы')

Core::ResearchArea.create!(name: 'Математика')

Core::ProjectKind.create!(name: 'Исследовательский')
