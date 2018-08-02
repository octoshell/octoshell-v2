module Core
  require "initial_create_helper"
  describe Organization do
    describe "#check_mergers" do
      before(:each) do
        @user = create(:user)
        @organization = create(:organization)
        @department = create(:organization_department, organization: @organization)
        @department1 = create(:organization_department, organization: @organization)


        @organization2 = create(:organization)
        @department2 = create(:organization_department, organization: @organization2)
        @organization3 = create(:organization)

        @organization.employments.create! user: @user
        @department.employments.create! user: @user,
                                        organization: @department.organization
        @project = create_project(organization: @organization)
        @project.members.create!(user: @user, organization: @organization)
      end

      it "merges to existing department successfully" do
        @department.merge_with_new_department!(@organization3.id)
        expect(@organization.department_mergers_any?).to eq true

        # @res, @message = @organization.merge_with_existing_department(@department2.organization_id,@department2.id)
        # expect(@message).to eq nil
        # expect(@res).to eq true
        # expect(Organization.count).to eq 1
        # expect(OrganizationDepartment.count).to eq 1
      end
    end
  end
end
