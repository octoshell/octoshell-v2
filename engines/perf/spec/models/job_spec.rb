module Perf
  require 'main_spec_helper'
  describe Job do
    before(:each) do
      @projects = 3.times.map do
        create(:project)
      end
      @session = create(:session)
      @inactive_project = create(:project)
      (@projects + [@inactive_project]).each do |pr|
        Sessions::ProjectsInSession.create!(project_id: pr.id,
                                            session_id: @session.id)
        pr.members.create!(user: create(:user),
                           organization: create(:organization))
      end
    end

    describe '::projects_by_node_hours' do
      it 'works' do
        time = DateTime.now
        jobs = []
        (@projects + [@projects.last]).each do |pr|
          pr.members.each do |member|
            jobs << Perf::Job.new(end_time: time, start_time: time - 1.year + 4.seconds, submit_time: DateTime.now - 5.seconds,
                                login: member.login, num_nodes: 2, state: 'COMPLETED', )
            jobs << Perf::Job.new(end_time: time, start_time: time - 1.year + 4.seconds,submit_time: DateTime.now - 5.seconds,
                                login: member.login, num_nodes: 2, state: 'COMPLETED')

            # jobs << Perf::Job.new(end_time: time, start_time: time - 1.year + 4.seconds,submit_time: DateTime.now - 5.seconds,
            #                     login: member.login, num_nodes: 2, state: 'FAILED')
          end
        end

        jobs << Perf::Job.new(end_time: time, start_time: time - 1.year + 4.seconds, submit_time: DateTime.now - 5.seconds,
                            login: @projects.second.members.first.login, num_nodes: 2, state: 'FAILED')
        jobs.each do |job|
          job.save(validate: false)
        end
        pp Comparator.new(@session.id).brief_project_stat.execute.group_by { |e| e['id']  }
        pp Comparator.new(@session.id).show_project_stat(['FAILED'], 's_share_node_hours').execute

      end
    end
  end
end
