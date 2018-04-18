module Core
  require "initial_create_helper"
  describe Organization do
    describe "#merge_to_new_department" do
      before(:each) do
        @organization = create(:organization)
        @organization2 = create(:organization)
      end
      it "creates  organization department" do
        @department, @message = @organization.merge_to_new_department(@organization2.id)
        expect(@message).to eq nil
        expect(Organization.count).to eq 1
        expect(OrganizationDepartment.count).to eq 1

      end
      it "doesn't create  department with empty name" do
        @res, @error = @organization.merge_to_new_department(@organization2.id, '')
        puts @error
        expect(OrganizationDepartment.count).to eq 0
      end
      it "doesn't destroy  organization with existing departments" do
        create(:organization_department, organization: @organization)
        @department, @message = @organization.merge_to_new_department(@organization2.id)
        expect(@organization2.departments.exists?).to eq false
        expect(@message).not_to eq nil
      end
      it "creates  department  and changes associated objects " do
        @project = create_project(organization: @organization)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization
        @member = @project.members.create!(user: @user,
                                           organization: @organization)
        @res, @message = @organization.merge_to_new_department(@organization2.id)
        @department = Core::OrganizationDepartment.first
        expect(@message).to eq nil
        expect(Organization.count).to eq 1
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
