module Core
  require 'main_spec_helper'
  describe OrganizationDepartment do
    describe "#merge_with_organization" do
      before (:each) do
        @organization = create(:organization)
        @department = create(:organization_department, organization: @organization)
        @organization2 = create(:organization)
      end

      it "works successfully" do
        @result, @message = @department.merge_with_organization(@organization2.id)
        expect(@result).to eq true
        expect(@message).to eq nil
        expect(OrganizationDepartment.all).to eq []

      end

      it "destroys department  and changes associated objects " do
        @project = create_project(organization: @organization,
                                  organization_department: @department)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization,
                                          organization_department: @department
        @member = @project.members.create!(user: @user,
                                           organization: @organization,
                                           organization_department: @department)
        @result, @message = @department.merge_with_organization(@organization2.id)
        expect(@result).to eq true
        expect(@message).to eq nil
        expect(OrganizationDepartment.all).to eq []
        expect(Employment.first.organization_department).to eq nil
        expect(Employment.first.organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization).to eq @organization2
        expect(Member.find_by(user_id: @user.id).organization_department)
          .to eq nil
        @project.reload
        expect(@project.organization).to eq @organization2
        expect(@project.organization_department)
          .to eq nil
      end

    end
  end
end
