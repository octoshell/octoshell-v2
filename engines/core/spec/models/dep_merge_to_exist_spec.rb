module Core
  require "initial_create_helper"
  describe OrganizationDepartment do
    describe "#merge_with_existing_department" do
      before (:each) do
        @organization = create(:organization)
        @department = create(:organization_department, organization: @organization)
        @organization2 = create(:organization)
        @department2 = create(:organization_department, organization: @organization2)

      end

      it "merges to existing department successfully" do
        @res, @message = @department.merge_with_existing_department(@department2.organization_id,@department2.id)
        expect(@res).not_to eq false
        expect(@message).to eq nil
        expect(OrganizationDepartment.all).to eq [@department2]
      end

      it "creates DepartmentMerger" do
        @department3 = create(:organization_department, organization: @organization2)
        @department1 = create(:organization_department,organization: @organization)
        @department2 = create(:organization_department,organization: @organization)
        @user = create(:user)
        @user_with_many_employments = create(:user)

        @department1.employments.create!(user: @user)
        @department1.employments.create!(organization: @organization, user: @user_with_many_employments)
        @department2.employments.create!(organization: @organization, user: @user_with_many_employments)
        @project = create_project
        @project.members.create!(user: @user,
                                organization: @organization)
        @project.members.create!(user: @user_with_many_employments,
                                organization: @organization)
        @res, @message = @department.merge_with_existing_department(@department3.organization_id,@department3.id)
        expect(@res.instance_of?(DepartmentMerger)).to eq true
        expect(@message).to eq nil
      end

      it "doesn't merge changed organization_department" do
        @res, @message = @department.merge_with_existing_department(@department2.organization_id + 1001,@department2.id)
        expect(@message).to eq 'stale_organization_id'
        expect(OrganizationDepartment.all).to match_array [@department, @department2]
      end


      it "changes associated objects " do
        @project = create_project(organization: @organization,
                                  organization_department: @department)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization,
                                          organization_department: @department
        @member = @project.members.create!(user: @user,
                                           organization: @organization,
                                           organization_department: @department)
        @res, @message = @department.merge_with_existing_department(@department2.organization_id,@department2.id)

        expect(@res).not_to eq false
        expect(@message).to eq nil
        expect(OrganizationDepartment.all).to eq [@department2]
        expect(Employment.first.organization_department).to eq @department2
        expect(Employment.first.organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization_department)
          .to eq @department2
        @project.reload
        expect(@project.organization).to eq @organization2
        expect(@project.organization_department)
          .to eq @department2
      end

      it "changes associated objects with nil department " do
        @project = create_project(organization: @organization,
                                  organization_department: @department)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization,
                                          organization_department: @department
        @member = @project.members.create!(user: @user,
                                           organization: @organization)
        @res, @message = @department.merge_with_existing_department(@department2.organization_id,@department2.id)

        expect(@res).not_to eq false
        expect(@message).to eq nil
        expect(OrganizationDepartment.all).to eq [@department2]
        expect(Employment.first.organization_department).to eq @department2
        expect(Employment.first.organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization_department)
          .to eq @department2
        @project.reload
        expect(@project.organization).to eq @organization2
        expect(@project.organization_department)
          .to eq @department2
      end


    end
  end
end
