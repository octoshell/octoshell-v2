require 'main_spec_helper'

feature 'Admin creates re-registration session with surveys and fields', js: true do
  background do
    # Create admin user
    @admin = create(:admin, email: 'admin@octoshell.ru', password: '123456')

    # Create survey kind for testing
    @survey_kind = Sessions::SurveyKind.create!(name: 'Test Survey Kind')

    # Create projects for testing
    @project1 = create(:project, title: 'Test Project 1', state: 'active')
    @project2 = create(:project, title: 'Test Project 2', state: 'active')

    # Set the project owners' state to allowed without validation
    @project1.member_owner.update_column(:project_access_state, 'allowed')
    @project2.member_owner.update_column(:project_access_state, 'allowed')

    # Sign in as admin
    sign_in(@admin)
  end

  scenario 'Admin successfully creates re-registration session, surveys, adds fields and starts it' do
    # Visit the new session page
    visit sessions.admin_sessions_path
    click_on 'Создать перерегистрацию'

    # Fill in session details
    fill_in 'Название (RU)', with: 'Test re-registration session'
    fill_in 'Название (EN)', with: 'Test re-registration session'
    fill_in 'Описание (RU)', with: 'Test motivation'
    fill_in 'Описание (EN)', with: 'Test motivation'
    fill_in 'Сдать до', with: Date.tomorrow.strftime('%Y-%m-%d')

    # Submit the session form
    click_on 'Продолжить'

    # Should be redirected to session show page
    expect(page).to have_content('Перерегистрация «Test re-registration session»')

    # Select projects for the session
    click_on 'Отобрать проекты-участники'

    # Check both projects by finding the checkbox elements directly
    find("input[type='checkbox'][value='#{@project1.id}']").click
    find("input[type='checkbox'][value='#{@project2.id}']").click

    # Save project selection
    click_on 'Сохранить'

    # Should be redirected back to session page
    expect(page).to have_content('Перерегистрация «Test re-registration session»')

    # Create a survey for regular users (only_for_project_owners: false)
    click_on 'Добавить опросник'
    fill_in 'Название (RU)', with: 'User Survey'
    fill_in 'Название (EN)', with: 'User Survey'
    # Don't select a template survey
    click_on 'Сохранить'

    # Should be redirected to survey page
    expect(page).to have_content('User Survey')

    # Add a field to the user survey
    click_on 'Добавить поле'
    fill_in 'Название (RU)', with: 'User Question'
    fill_in 'Название (EN)', with: 'User Question'
    # Select 'Короткий текст' for kind using select2 helper
    select2 'Короткий текст', from: 'Тип'
    click_on 'Сохранить'

    # Should be redirected back to survey page with the new field
    expect(page).to have_content('User Question')

    # Go back to session page
    click_on 'Вернуться к перерегистрации'

    # Create a survey for project owners (only_for_project_owners: true)
    click_on 'Добавить опросник'
    fill_in 'Название (RU)', with: 'Project Owner Survey'
    fill_in 'Название (EN)', with: 'Project Owner Survey'
    # Don't select a template survey
    # Check 'Только для руководителей проектов'
    check 'survey_only_for_project_owners'
    click_on 'Сохранить'

    # Should be redirected to survey page
    expect(page).to have_content('Project Owner Survey')

    # Add a field to the project owner survey
    click_on 'Добавить поле'
    fill_in 'Название (RU)', with: 'Project Owner Question'
    fill_in 'Название (EN)', with: 'Project Owner Question'
    # Select 'Список' for kind using select2 helper
    select2 'Список', from: 'Тип'
    fill_in 'Значения', with: "Option 1\nOption 2\nOption 3"
    click_on 'Сохранить'

    # Should be redirected back to survey page with the new field
    expect(page).to have_content('Project Owner Question')

    # Go back to session page
    click_on 'Вернуться к перерегистрации'
    # Verify both surveys are listed
    within 'ul.list-unstyled' do
      expect(page).to have_content('User Survey')
      expect(page).to have_content('Project Owner Survey')
    end

    # Check if the start button is enabled
    start_button = find('a', text: 'Начать')
    expect(start_button[:disabled]).to be_nil # Button should not be disabled

    # Click the start button and accept the confirmation dialog
    accept_confirm do
      click_on 'Начать'
    end

    sleep 1
    # Verify session was created successfully
    session = Sessions::Session.last
    expect(session.description).to eq('Test re-registration session')
    expect(session.surveys.count).to eq(2)

    # Verify session is active
    expect(session.state).to eq('active')
    expect(session.started_at).not_to be_nil

    # Verify projects are associated with the session
    expect(session.involved_project_ids).to include(@project1.id, @project2.id)

    # Verify surveys have correct settings
    user_survey = session.surveys.find_by(name_ru: 'User Survey')
    expect(user_survey.only_for_project_owners).to be_falsey
    expect(user_survey.fields.count).to eq(1)
    expect(user_survey.fields.first.name_ru).to eq('User Question')

    owner_survey = session.surveys.find_by(name_ru: 'Project Owner Survey')
    expect(owner_survey.only_for_project_owners).to be_truthy
    expect(owner_survey.fields.count).to eq(1)
    expect(owner_survey.fields.first.name_ru).to eq('Project Owner Question')

    # Wait a bit for the Sidekiq job to complete

    # Reload session to get updated data
    expect(session.reports.count).to be > 0
  end
end
