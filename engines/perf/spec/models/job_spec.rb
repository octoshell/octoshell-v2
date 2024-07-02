require 'main_spec_helper'
module Perf
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
      time = DateTime.now - 1.hours
      (@projects + [@projects.last]).each do |pr|
        pr.members.each do |member|
          2.times do
            create(:job, login: member.login, end_time: time)
          end
        end
      end
      login = @projects.second.members.first.login
      create(:job, login: login, end_time: time, state: 'FAILED')

    end


    describe '::projects_by_node_hours' do
      it 'shows place correctly' do
        rows = Comparator.new(@session.id).brief_project_stat.execute
        expect(rows).to include(include('id'=> @projects.last.id,
                                       's_place_node_hours' => 1,
                                       's_node_hours' => (3 * 2 * 2 * 2 * 2)))
        # pp Comparator.new(@session.id).brief_project_stat.execute.group_by { |e| e['id']  }
        # pp Comparator.new(@session.id).show_project_stat(['FAILED'], 's_share_node_hours').execute
      end

      it 'formats correctly' do
        rows = Comparator.new(@session.id).brief_project_stat.execute
        pp ComparatorFormatter.call(rows)
      end
    end
  end
end
