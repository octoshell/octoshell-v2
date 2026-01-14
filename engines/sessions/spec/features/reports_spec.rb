require 'main_spec_helper'

feature 'Project owner fills reports on /sessions/reports page' do
  background do
    # Create a project (default owner will be created via factory)
    @project = create(:project, title: 'Test Project', state: 'active')
    @owner = @project.member_owner.user
    # Ensure owner is allowed
    @project.member_owner.update_column(:project_access_state, 'allowed')

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

    # Start the session to create reports (since session is already active, reports are created)
    @session.create_reports_and_users_surveys

    # Get the report for the project
    @report = @project.reports.where(session: @session).first
    expect(@report).not_to be_nil
    expect(@report.author).to eq(@owner)

    # Sign in as project owner
    sign_in(@owner)
  end

  scenario 'Project owner fills report with file upload and submits' do
    # Visit the report show page directly
    visit sessions.report_path(@report)

    # Report is pending, need to accept it
    expect(@report.reload.state).to eq('pending')
    expect(page).to have_link('Начать заполнение отчета') # based on locale

    # Accept the report (move to accepted state)
    click_on 'Начать заполнение отчета'

    # Now the report is in accepted state, file upload form should be present
    expect(page).to have_css('legend', text: 'Прикрепить материалы отчета')
    expect(@report.reload.state).to eq('accepted')

    # Create a temporary ZIP file for upload (allowed extension)
    file_path = Rails.root.join('tmp/test.zip')
    File.open(file_path, 'w') { |f| f.write('dummy zip content') }
    # Attach the file within the report submission form
    within("form[action*='submit']") do
      attach_file 'report_report_material_materials', file_path
      # Ensure submit button is present
      expect(page).to have_button('Отправить')
      # Submit the report (there are two submit buttons, this ensures we click the correct one)
      click_button 'Отправить'
    end
    # After submit, state should become submitted
    expect(@report.reload.state).to eq('submitted')
    # Should stay on the report page
    expect(current_path).to eq(sessions.report_path(@report))
    # Clean up
    File.delete(file_path) if File.exist?(file_path)
  end
end
