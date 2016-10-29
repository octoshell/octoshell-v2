# encoding: utf-8

require "spec_helper"

feature "Working with projects", js: true do
  background do
    sign_in(seed(:user))
  end

  scenario "project creation" do
    visit core.new_project_path

    fill_in "Наименование", with: "Сложная система уравнений в частных производных"
    fill_in "Описание", with: "Решать будем методом научного тыка и подбора."

    click_on "Сохранить"

    expect(page).to have_content("Проект создан")
  end

  scenario "request to cluster creation" do
    cluster = seed(:cluster)
    project = seed(:project)

    visit core.project_path(project)
    within("#spare-clusters") do
      click_on "Запросить доступ"
    end

    click_button "Сохранить"

    expect(page).to have_content("Заявка создана")
    within("#requests") do
      expect(page).to have_content(cluster.name)
    end
  end

  scenario "member addition" do
    project = seed(:project)
    new_member = create(:user)

    visit core.project_path(project)
    click_link "member_adder"

    within(".new-member-form") do
      fill_in "email", :with => new_member.email
      click_button "Добавить участника"
    end

    expect(page).to have_content(new_member.email)
    expect(page).to have_content(project.members.first.login)
  end
end

feature "Obtaining access to clusters", js: true do
  scenario "obtaining access to cluster" do
    user = seed(:user)
    admin = seed(:admin)
    cluster = seed(:cluster)
    project = seed(:project)

    sign_in(user)
    visit core.project_path(project)
    within("#spare-clusters") do
      click_on "Запросить доступ"
    end
    click_button "Сохранить"
    sign_out

    sign_in(admin)
    visit core.admin_requests_path
    click_on "Подтвердить"
    sign_out

    sign_in(seed(:user))
    visit core.project_path(project)
    within("#accesses") do
      expect(page).to have_content(cluster.name)
    end
    sign_out
  end
end
