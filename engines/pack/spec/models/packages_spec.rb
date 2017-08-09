module Pack
	
	require "spec_helper"
	

	describe Package do
		

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
