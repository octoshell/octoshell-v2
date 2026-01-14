require 'main_spec_helper'

feature 'User fills surveys on /sessions/surveys page', js: true do
  background do
    # Create survey kind
    @survey_kind = Sessions::SurveyKind.create!(name: 'Test Survey Kind')

    # Create a project
    @project = create(:project, title: 'Test Project', state: 'active')
    @project.member_owner.update_column(:project_access_state, 'allowed')

    # Create a regular user who is a member of the project
    @user = create(:user, email: 'user@example.com', password: '123456')
    @project.members.create!(user: @user, project_access_state: 'allowed')

    # Create a session
    @session = Sessions::Session.create!(
      description_ru: 'Test re-registration session',
      description_en: 'Test re-registration session',
      motivation_ru: 'Test motivation',
      motivation_en: 'Test motivation',
      receiving_to: Date.tomorrow,
      state: 'active',
      started_at: Time.zone.now
    )

    # Associate project with session
    @session.involved_projects << @project

    # Create a survey (not only for project owners)
    @survey = @session.surveys.create!(
      name_ru: 'User Survey',
      name_en: 'User Survey',
      only_for_project_owners: false,
      kind: @survey_kind
    )

    # Add a field to the survey
    @field = @survey.fields.create!(
      name_ru: 'User Question',
      name_en: 'User Question',
      kind: 'string',
      required: false
    )

    # Create user_survey for the regular user (pending)
    @user_survey = Sessions::UserSurvey.create!(
      user: @user,
      session: @session,
      survey: @survey,
      project: @project,
      state: 'pending'
    )

    # Sign in as regular user
    sign_in(@user)
  end

  scenario 'User fills survey with text field and submits' do
    visit sessions.user_surveys_path

    # Expect to see the survey in the list
    expect(page).to have_content('User Survey')

    # Click on the survey to go to its show page
    click_on 'User Survey'

    # Survey is pending, need to accept it
    expect(@user_survey.reload.state).to eq('pending')
    expect(page).to have_link('Пройти') # based on locale

    # Accept the survey (move to filling state)
    click_on 'Пройти'

    # Now the survey is in filling state, form should be present
    expect(page).to have_content('User Question')
    expect(@user_survey.reload.state).to eq('filling')

    # Fill in the field
    find("input[name='fields[#{@field.id}]']").set('Some answer')

    # Submit the survey (click the submit button)
    click_on 'Отправить'

    # After submit, state should become submitted
    expect(@user_survey.reload.state).to eq('submitted')
    # Should stay on the survey page, possibly with a success message
    expect(page).to have_content('User Survey')
    expect(page).to have_link('Редактировать') # edit button appears after submission
    # Submit button should disappear
    expect(page).to have_no_button('Отправить')
  end
end
