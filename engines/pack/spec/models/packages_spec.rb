module Pack
	
	require "spec_helper"
	

	describe Package do
		
		it "left joins accesses and versions" do

		  package = create(:package)
		  @packages = Package.joins("LEFT JOIN pack_versions on pack_versions.package_id=pack_packages.id")   
          @packages = @packages.merge( Version.left_join_user_accesses( User.first.id ) )
          expect(@packages).to eq([package])
		end

		it "deletes package,package's versions,versions' accesses" do

		  package = create(:package)
		  version = create(:version,package: package)
		  access = access_with_status(version: version)
		  package.update!(deleted: true)

          expect(Package.first.deleted).to eq( true )
          expect(Version.first.deleted).to eq( true )
          expect(Access.first.status).to eq( "deleted" )
		end
	end
		
	
		


end
