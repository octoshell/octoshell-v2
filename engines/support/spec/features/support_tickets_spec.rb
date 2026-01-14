require 'main_spec_helper'

feature 'Working with support tickets', js: true do
  background do
    @user = create(:user)
    sign_in(@user)
    create(:topic, visible_on_create: true)
    @topic = create(:topic, visible_on_create: true)
  end

  scenario 'user creates a new support ticket' do
    visit support.new_ticket_path

    # First step: select topic
    select2 @topic.name_ru, from: Support::Ticket.human_attribute_name(:topic)
    click_on I18n.t('actions.next')

    # Second step: fill in ticket details
    fill_in Support::Ticket.human_attribute_name(:subject), with: 'Test Support Ticket'
    fill_in Support::Ticket.human_attribute_name(:message), with: 'This is a test support ticket message.'

    click_on I18n.t('actions.save')

    expect(page).to have_content('Test Support Ticket')
    expect(page).to have_content(I18n.t('activerecord.aasm.support/ticket.state.states.pending'))
  end
end
