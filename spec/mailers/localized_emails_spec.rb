require 'main_spec_helper'
describe LocalizedEmails, type: :mailer do
  it 'delivers Test Mail' do
    @users = []
    @users << create(:user)
    @users << create(:user, email: 'eng@octoshell.uk', language: 'en')
    @users << create(:user)
    @users << create(:user, email: 'eng_2@octoshell.uk', language: 'en')
    @collection = TestMailer.test_mail(@users.map(&:email) + ['vasya@mail.ru']).message
    expect(@collection.mails.map(&:to)).to match_array([ [@users[0], @users[2]].map(&:email), [@users[1],@users[3]].map(&:email) + ['vasya@mail.ru'] ] )
    expect { TestMailer.test_mail(@users.map(&:email) + ['vasya@mail.ru']).deliver! }.to change { ActionMailer::Base.deliveries.count }.by(2)
  end
  it 'delivers Core::Mailer.project_activated mail' do
    @users = []
    @users << create(:user)
    @users << create(:user, email: 'eng@octoshell.uk', language: 'en')
    @users << create(:user)
    @users << create(:user, email: 'eng_2@octoshell.uk', language: 'en')
    @project = create(:project)
    @users.each do |u|
      @project.members.create!(user: u, project_access_state: :allowed)
    end
    @collection = Core::Mailer.project_activated(@project.id).message
    ru_subject = I18n.t('core.mailer.project_activated.subject', locale: :ru, title: @project.title)
    en_subject = I18n.t('core.mailer.project_activated.subject', locale: :en, title: @project.title)

    expect(@collection.mails.map(&:to)).to match_array([ [@users[0], @users[2]].map(&:email),
                                                         [@users[1], @users[3]].map(&:email) ] )
    expect(@collection.mails.map(&:subject)).to eq [ru_subject, en_subject]
    expect { Core::Mailer.project_activated(@project.id).deliver! }.to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  it 'does not send to blocked emails' do
    @users = [
      create(:user, block_emails: true),
      create(:user)
    ]
    expect { TestMailer.test_mail(@users.map(&:email) + ['vasya@mail.ru']).deliver! }
      .to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  it 'sends to blocked emails if @non_blocking_delivery is set' do
    blocked_user = create(:user, block_emails: true)
    expect { Authentication::Mailer.activation_success(blocked_user.email).deliver! }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

end
