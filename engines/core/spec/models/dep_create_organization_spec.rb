module Core
  require 'main_spec_helper'
  describe OrganizationDepartment do
    describe "#create_organization" do
      before(:each) do
        @department = create(:organization_department)
        @organization = @department.organization
        @kind = create(:organization_kind)
        @city = create(:city)
        @country = @city.country
        @hash = { kind_id: @kind.id, city_id: @city.id, country_id: @country.id,
                  name: 'new_organization' }

      end
      it "creates organization successfully" do
        @res, @message = @department.create_organization(@hash)
        expect(@message).to eq nil
        expect(@res).to eq Organization.find_by name: 'new_organization'
        expect(Organization.all.to_a).to match_array [@organization, @res]
        expect(OrganizationDepartment.all.to_a).to eq []
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
        @res, @message = @department.create_organization(@hash)
        expect(@res).to eq Organization.find_by name: 'new_organization'
        expect(@message).to eq nil
        expect(OrganizationDepartment.all.to_a).to eq []
        expect(Employment.first.organization_department).to eq nil
        expect(Employment.first.organization).to eq @res
        expect(Member.find_by(user_id: @user.id).organization).to eq @res
        expect(Member.find_by(user_id: @user.id).organization_department)
          .to eq nil
        @project.reload
        expect(@project.organization).to eq @res
        expect(@project.organization_department)
          .to eq nil
      end
    end
  end
end
