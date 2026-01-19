require 'main_spec_helper'
module Jobstat
  def self.create_job(attributes = {})
    Jobstat::Job.create!(FactoryBot.build(:job, attributes).attributes)
  end
  describe Job do
    describe '#notify_when_finished' do
      it 'notifies when COMPLETED job is created' do
        expect(Core::BotLinksApiHelper).to receive :job_finished
        Jobstat.create_job.notify_when_finished
      end

      it 'does not notify' do
        job = Jobstat.create_job.reload
        expect(Core::BotLinksApiHelper).not_to receive :job_finished
        job.update!(state: 'FAILED')
        job.notify_when_finished
      end

      it 'notifies when job moves from RUNNING to COMPLETED state' do
        job = Jobstat.create_job(state: 'RUNNING').reload
        expect(Core::BotLinksApiHelper).to receive :job_finished
        job.update!(state: 'COMPLETED')
        job.notify_when_finished
      end
    end

    # describe '_update_job' do
    #   it 'raises exception with 2 threads' do
    #     expect do
    #       2.times.map do |i|
    #         Thread.new do
    #           Job._update_job({ 'cluster' => 'cluster',
    #                             'state' => 'RUNNING',
    #                             'job_id' => 1,
    #                             'task_id' => 1,
    #                             'account' => "account_#{i}",
    #                             'partition' => 'compute' }
    #                             .merge(%w[t_submit t_end t_start]
    #                                 .map { |a| [a, Time.now] }.to_h))
    #         end
    #       end.each(&:join)
    #     end.to raise_error(ActiveRecord::RecordNotUnique)
    #   end
    # end

    describe '::update_job' do
      it 'does not overwrite final state with initial state' do
        Job.update_job({ 'cluster' => 'cluster',
                         'state' => 'COMPLETED',
                         'job_id' => 1,
                         'task_id' => 1,
                         'account' => 'account',
                         'partition' => 'compute' }
                         .merge(%w[t_submit t_end t_start]
                              .map { |a| [a, Time.now] }.to_h))

        Job.update_job({ 'cluster' => 'cluster',
                         'state' => 'RUNNING',
                         'job_id' => 1,
                         'task_id' => 1,
                         'account' => 'account',
                         'partition' => 'compute' }
                         .merge(%w[t_submit t_end t_start]
                              .map { |a| [a, Time.now] }.to_h))

        expect(Job.find_by(drms_job_id: 1, drms_task_id: 1).state).to eq 'COMPLETED'
      end

      it 'overwrites final state with final state' do
        Job.update_job({ 'cluster' => 'cluster',
                         'state' => 'COMPLETED',
                         'job_id' => 1,
                         'task_id' => 1,
                         'account' => 'account',
                         'partition' => 'compute' }
                         .merge(%w[t_submit t_end t_start]
                              .map { |a| [a, Time.now] }.to_h))

        Job.update_job({ 'cluster' => 'cluster',
                         'state' => 'NODE_FAIL',
                         'job_id' => 1,
                         'task_id' => 1,
                         'account' => 'account',
                         'partition' => 'compute' }
                         .merge(%w[t_submit t_end t_start]
                              .map { |a| [a, Time.now] }.to_h))

        expect(Job.find_by(drms_job_id: 1, drms_task_id: 1).state).to eq 'NODE_FAIL'
      end

      it 'overwrites initial state with initial state' do
        Job.update_job({ 'cluster' => 'cluster',
                         'state' => 'RESIZING',
                         'job_id' => 1,
                         'task_id' => 1,
                         'account' => 'account',
                         'partition' => 'compute' }
                         .merge(%w[t_submit t_end t_start]
                              .map { |a| [a, Time.now] }.to_h))

        Job.update_job({ 'cluster' => 'cluster',
                         'state' => 'RUNNING',
                         'job_id' => 1,
                         'task_id' => 1,
                         'account' => 'account',
                         'partition' => 'compute' }
                         .merge(%w[t_submit t_end t_start]
                              .map { |a| [a, Time.now] }.to_h))

        expect(Job.find_by(drms_job_id: 1, drms_task_id: 1).state).to eq 'RUNNING'
      end

      # it "works with 2 threads" do
      #   2.times.map do |i|
      #     Thread.new do
      #       Job.update_job({ 'cluster' => 'cluster',
      #                        'job_id' => 1,
      #                        'task_id' => 1,
      #                        'account' => "account_#{i}",
      #                        'partition' => 'compute' }
      #                        .merge(%w[t_submit t_end t_start]
      #                             .map { |a| [a, Time.now] }.to_h))
      #     end
      #   end.each(&:join)
      #   expect(Job.where(cluster: 'cluster', drms_job_id: 1, drms_task_id: 1,
      #                    partition: 'compute').count).to eq 1
      # end
    end
  end
end
