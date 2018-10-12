module Core
  require 'main_spec_helper'
  describe Organization do
    describe "#merge_with_new_department!" do
      before(:each) do
        @organization = create(:organization)
        @organization2 = create(:organization)
      end
      it "creates  organization department" do
        @department, @message = @organization.merge_with_new_department!(@organization2.id)
        expect(@message).to eq nil
        expect(Organization.count).to eq 1
        expect(OrganizationDepartment.count).to eq 1

      end
      it "doesn't create  department with empty name" do
        lambda {  @organization.merge_with_new_department!(@organization2.id, '') }.should raise_error
      end
      it "doesn't destroy  organization with existing departments" do
        create(:organization_department, organization: @organization)
        lambda { transaction do
          @organization.merge_with_new_department!(@organization2.id)
        end
           }.should raise_error
         expect(@organization2.departments.exists?).to eq false
      end
      it "creates  department  and changes associated objects " do
        @project = create_project(organization: @organization)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization
        @member = @project.members.create!(user: @user,
                                           organization: @organization)
        @res, @message = @organization.merge_with_new_department!(@organization2.id)
        @department = Core::OrganizationDepartment.first
        expect(@res).to eq @department
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
