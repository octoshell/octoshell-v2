require 'main_spec_helper'
module Jobstat
  def self.create_job(attributes = {})
    Jobstat::Job.create!(FactoryBot.build(:job, attributes).attributes)
  end
  describe Job do
    describe "#notify_when_finished" do
      it "notifies when COMPLETED job is created" do
        expect(Core::BotLinksApiHelper).to receive :job_finished
        Jobstat.create_job.notify_when_finished
      end

      it "does not notify" do
        job = Jobstat.create_job.reload
        expect(Core::BotLinksApiHelper).not_to receive :job_finished
        job.update!(state: 'FAILED')
        job.notify_when_finished
      end

      it "notifies when job moves from RUNNING to COMPLETED state" do
        job = Jobstat.create_job(state: 'RUNNING').reload
        expect(Core::BotLinksApiHelper).to receive :job_finished
        job.update!(state: 'COMPLETED')
        job.notify_when_finished
      end

    end
  end

end
