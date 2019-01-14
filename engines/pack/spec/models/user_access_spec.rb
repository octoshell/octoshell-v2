




module Pack
  require 'main_spec_helper'
  describe Access do
    describe "#user_access" do
      before(:each) do
           Group.default!
         @user = create_admin#create(:user)
         @user2 = create_admin
        @package = create(:package)
        @version  = create(:version,package: @package)
        @project = create_project
        @project.members.create!(user: @user )
      end
        it "1" do
          access1 = access_with_status( {who: @user,version: @version} )
          access2 = access_with_status( {who: @project,version: @version} )
          accesses = Access.user_access(@user.id)
          expect(accesses).to eq( [access1,access2] )
        end
        it "2" do
          access_with_status( {who: @user2,version: @version} )
          access2 = access_with_status( {who: @project,version: @version} )
          accesses = Access.user_access(@user.id)
          expect(accesses).to eq( [access2] )
        end
        it "3" do
          access1 = access_with_status( {who: Group.find_by(name: "superadmins"),version: @version} )
          access2 = access_with_status( {who: @project,version: @version} )
          accesses = Access.user_access(@user.id)
          expect(accesses).to eq( [access1,access2] )
        end
        it "4" do
          access1 = access_with_status( {who: Group.find_by(name: "superadmins"),version: @version} )
          access2 = access_with_status( {who: @project,version: @version} )
          accesses = Access.user_access(@user.id)
          expect(accesses).to eq( [access1,access2] )
        end

        it "5" do
          access1 = access_with_status( {who: Group.find_by(name:"experts"),version: @version} )
          access2 = access_with_status( {who: create_project,version: @version} )
          access3 = access_with_status( {who: create_admin,version: @version} )
          accesses = Access.user_access(@user.id)
          expect(accesses).to eq( [] )
        end
    end
  end
end
