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

    describe "_update_job" do
      it "raises exception with 2 threads" do
        expect {
          2.times.map do |i|
            Thread.new do
              Job._update_job({ 'cluster' => 'cluster',
                                'job_id' => 1,
                                'task_id' => 1,
                                'account' => "account_#{i}",
                                'partition' => 'compute' }
                                .merge(%w[t_submit t_end t_start]
                                    .map { |a| [a, Time.now] }.to_h))
            end
          end.each(&:join)
        }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe "update_job" do
      it "works with 2 threads" do
        2.times.map do |i|
          Thread.new do
            Job.update_job({ 'cluster' => 'cluster',
                             'job_id' => 1,
                             'task_id' => 1,
                             'account' => "account_#{i}",
                             'partition' => 'compute' }
                             .merge(%w[t_submit t_end t_start]
                                  .map { |a| [a, Time.now] }.to_h))
          end
        end.each(&:join)
        expect(Job.where(cluster: 'cluster', drms_job_id: 1, drms_task_id: 1,
                         partition: 'compute').count).to eq 1
      end
    end


  end

end
