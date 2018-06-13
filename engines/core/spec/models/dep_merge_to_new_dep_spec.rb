module Core
  require "initial_create_helper"
  describe OrganizationDepartment do
    describe "#merge_with_new_department" do
      before(:each) do
        @organization = create(:organization)
        @department = create(:organization_department, organization: @organization)
        @organization2 = create(:organization)
      end
      it "1" do
        @res, @message = @department.merge_with_new_department(@organization2.id)
        expect(@message).to eq nil
        expect(@organization2.departments.first.id).to eq @department.id
        expect(OrganizationDepartment.count).to eq 1
      end

      it "doesn't create  department with empty name" do
        @res, @message = @department.merge_with_new_department(@organization2.id, '')
        puts @message
        expect(OrganizationDepartment.all).to eq [@department]
      end

      it "creates  department  and changes associated objects " do
        @project = create_project(organization: @organization,
                                  organization_department: @department)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization,
                                          organization_department: @department
        @member = @project.members.create!(user: @user,
                                           organization: @organization,
                                           organization_department: @department)
        @res, @message = @department.merge_with_new_department(@organization2.id)

        @department.reload
        puts @message
        expect(@res).to eq @department
        expect(@message).to eq nil
        expect(@organization2.departments).to eq [@department]
        expect(OrganizationDepartment.count).to eq 1
        expect(Employment.first.organization_department).to eq @department
        expect(Employment.first.organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization_department)
          .to eq @department
        @project.reload
        expect(@project.organization).to eq @organization2
        expect(@project.organization_department)
          .to eq @department
      end
    end
  end
end
