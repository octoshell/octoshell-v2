require 'main_spec_helper'

feature 'Working with clasters', js: true do
  background do
    sign_in(create_admin)
  end

  scenario 'cluster creation' do
    visit core.admin_clusters_path
    click_on 'Новый кластер'

    fill_in 'Наименование (RU)', with: 'Лейбниц'
    fill_in 'Хост', with: 'leibniz.ru'
    fill_in 'Логин администратора', with: 'gottfried'
    #
    # click_on "+ добавить квоту"
    # fill_in "Название(RU)", with: "CPU"
    # fill_in "Значение(RU)", with: "5"

    click_on 'Сохранить'

    expect(page).to have_content('Кластер создан')
  end
end
