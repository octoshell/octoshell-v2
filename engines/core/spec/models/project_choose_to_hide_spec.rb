require 'main_spec_helper'
module Core
  RSpec.describe Project do
    before(:each) do
      @project_no_resources = create_project
      @project_resources = create_project(title: 'project_resources')
      @project_resources_one_member_deleted = create_project
      @project_resources_all_members_deleted = create_project
      @end_date = DateTime.new(2023, 1, 19)
      @start_date = @end_date - 1.years
      @job_start = @start_date + 10.seconds
      @job_end = @job_start + 1.hours

      [@project_resources, @project_resources_one_member_deleted,
       @project_resources_all_members_deleted].each do |pr|
        2.times do
          member = pr.members.create!(user: create(:user),
                                      project_access_state: 'allowed')
          Perf::Job.create!(start_time: @job_start, end_time: @job_end,
                            submit_time: @start_date, login: member.login,
                            cluster: 'super_duper_cluster',
                            drms_job_id: 1,
                            num_cores: 10, state: 'COMPLETED')
        end
      end
      @project_resources_one_member_deleted.drop_member(@project_resources_one_member_deleted.members.last.user_id)
      @project_resources_all_members_deleted.members.each do |m|
        unless m == @project_resources_all_members_deleted.owner
          @project_resources_all_members_deleted.drop_member(m.user_id)
        end
      end
    end

    describe '::choose_to_hide' do
      it 'does not show projects consumed 0 num_cores' do
        expect(Project.choose_to_hide(1, @start_date, nil, @end_date, nil))
          .not_to include(@project_no_resources)
        expect(Project.choose_to_hide(2, @start_date, nil, @end_date, nil))
          .not_to include(@project_no_resources)
        expect(Project.choose_to_hide(1, @start_date, 0, @end_date, nil))
          .not_to include(@project_no_resources)
        expect(Project.choose_to_hide(2, @start_date, 0, @end_date, nil))
          .not_to include(@project_no_resources)
      end

      it 'shows only projects consumed 0 resources when core_hours_lt=0 passed' do
        rel1 = Project.choose_to_hide(1, @start_date, nil, @end_date, 0)
        expect(rel1).to include(@project_no_resources, @project_resources_all_members_deleted)
        expect(rel1).not_to include(@project_resources,
                                    @project_resources_one_member_deleted)
        rel2 = Project.choose_to_hide(2, @start_date, nil, @end_date, 0)
        expect(rel2).to include(@project_no_resources)
        expect(rel2).not_to include(@project_resources,
                                    @project_resources_one_member_deleted,
                                    @project_resources_all_members_deleted)
      end

      it 'shows projects consumed resources' do
        expect(Project.choose_to_hide(1, @start_date, nil, @end_date, nil))
          .to contain_exactly(@project_resources, @project_resources_one_member_deleted)
        expect(Project.choose_to_hide(2, @start_date, nil, @end_date, nil))
          .to contain_exactly(@project_resources,
                              @project_resources_one_member_deleted,
                              @project_resources_all_members_deleted)
      end

      it 'shows projects consumed resources of specific range' do
        expect(Project.choose_to_hide(1, @start_date, 1, @end_date, 21))
          .to contain_exactly(@project_resources, @project_resources_one_member_deleted)

        expect(Project.choose_to_hide(1, @start_date, 1, @end_date, 11))
          .to contain_exactly(@project_resources_one_member_deleted)

        expect(Project.choose_to_hide(2, @start_date, 19, @end_date, 21))
          .to contain_exactly(@project_resources,
                              @project_resources_one_member_deleted,
                              @project_resources_all_members_deleted)
        expect(Project.choose_to_hide(2, @start_date, 21, @end_date, nil).count)
          .to eq(0)
      end
    end
  end
end
