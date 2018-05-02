module Core
  require "initial_create_helper"
  describe Organization do
    describe "#merge_to_existing_department" do
      before (:each) do
        @organization = create(:organization)
        @organization2 = create(:organization)
        @department2 = create(:organization_department, organization: @organization2)
      end
      it "merges to existing department successfully" do
        @res, @message = @organization.merge_to_existing_department(@department2.organization_id,@department2.id)
        expect(@message).to eq nil
        expect(@res).to eq true
        expect(Organization.count).to eq 1
        expect(OrganizationDepartment.count).to eq 1
      end
      it "doesn't destroy  organization with existing departments" do
        create(:organization_department, organization: @organization)
        @res, @message = @organization.merge_to_existing_department(@department2.organization_id,@department2.id)
        expect(@res).to eq false
        puts @message
        expect(Organization.all).to match_array [@organization, @organization2]
      end
      it "changes associated objects " do
        @project = create_project(organization: @organization)
        @user = create_admin
        @organization.employments.create! user: @user,
                                          organization: @organization
        @member = @project.members.create!(user: @user,
                                           organization: @organization)
       @res, @message = @organization.merge_to_existing_department(@department2.organization_id,@department2.id)

        expect(@message).to eq nil
        expect(Organization.all).to eq [@organization2]
        expect(@res).to eq true
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
