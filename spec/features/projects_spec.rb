require 'main_spec_helper'

feature 'Working with projects', js: true do
  background do
    create(:project)
    @user = create(:user)
    sign_in(@user)
    @organization = create(:organization, checked: true)
    @organization.employments.create!(user: @user)
  end

  scenario 'project creation' do
    visit core.new_project_path
    fill_in 'Наименование', with: 'Сложная система уравнений в частных производных'
    select Core::ProjectKind.first.name_ru, from: 'Тип'
    select @organization.name, from: 'Организация'
    select Core::ResearchArea.first.name_ru, from: 'Область науки'
    ['Полное название', 'Задача', 'Стратегия', 'Цель', 'Эффект', 'Использование',
     'Project title', 'Driver', 'Strategy', 'Objective', 'Impact',
     'Usage'].each do |elem|
      fill_in elem, with: elem
    end
    fill_in 'Примерная дата окончания работ над проектом', with: Date.today + 30
    [Core::DirectionOfScience, Core::CriticalTechnology].each do |model|
      check model.first.name_ru
    end
    click_on 'Сохранить'

    expect(page).to have_content('Проект создан')
  end

  scenario 'request to cluster creation' do
    cluster = create(:cluster)
    project = create(:project, owner: @user)
    # project.members.create!(user: @user, organization: @organization,
    #                         project_access_state: 'allowed')

    visit core.project_path(project)
    within('#spare-clusters') do
      click_on 'Запросить доступ'
    end

    click_button 'Сохранить'

    expect(page).to have_content('Заявка создана')
    within('#requests') do
      expect(page).to have_content(cluster.name)
    end
  end

  # TODO: fix remote autocomplete
  # scenario "member addition" do
  #   project = create(:project, owner: @user)
  #   new_member = create(:user)
  #
  #   visit core.project_path(project)
  #   click_link "member_adder"
  #
  #   select new_member.full_name_with_cut_email, from: 'member[id]'
  #   click_button "Добавить участника"
  #
  #   expect(page).to have_content(new_member.email)
  #   expect(page).to have_content(project.members.first.login)
  # end
end

feature 'Obtaining access to clusters', js: true do
  scenario 'obtaining access to cluster' do
    admin = create(:admin)
    cluster = create(:cluster)
    user = create(:user)
    organization = create(:organization, checked: true)
    organization.employments.create!(user: user)
    project = create(:project, owner: user)

    sign_in(user)
    visit core.project_path(project)
    within('#spare-clusters') do
      click_on 'Запросить доступ'
    end
    click_button 'Сохранить'
    sign_out

    sign_in(admin)
    visit core.admin_request_path(Core::Request.last)
    fill_in 'request_reason', with: 'I AM BIG RUSSIAN ADMIN'
    click_on 'Подтвердить'
    sign_out

    sign_in(user)
    visit core.project_path(project)
    within('#accesses') do
      expect(page).to have_content(cluster.name)
    end
    sign_out
  end
end
