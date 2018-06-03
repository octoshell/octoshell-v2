module Core
  require "initial_create_helper"
  describe OrganizationDepartment do
    describe "::remove_spaces" do
      it "1" do
        @organization = create(:organization, name: '  space f   d ')
        expect(@organization.name).to eq 'space f d'
      end
    end
  end
end
