require 'main_spec_helper'

module Core
  def self.create_job(attributes = {})
    Jobstat::Job.find(FactoryBot.create(:job, attributes).id)
  end

  describe BotLinksApiHelper do
    describe "::notify_about_jobs" do
      before(:each) do
        @api = Core::BotLinksApiHelper.clone
      end

      it 'does not notify when login does not exist' do
        expect(@api).not_to receive(:notify)
        @api.job_finished(Core.create_job(login: 'none').id)
      end

      it 'notifes' do
        user = create(:user)
        user.profile.update!(notify_about_jobs: true)
        project = create(:project, owner: user)
        user.bot_links.create!(active: true, token: 'very_secret')
        expect(@api).to receive(:notify)
        @api.job_finished(Core.create_job(login: project.member_owner.login).id)
      end


    end
  end
end
