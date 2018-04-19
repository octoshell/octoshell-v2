module Pack
	
	require "spec_helper"
	

	describe "Pack::Access and Version expired testing" do
		
		it "marks expired versions and accesses as deleted" do

			@access=access_with_status_without_validation(status: "allowed",end_lic: AmericanDate.yesterday.to_s,forever: false) 
			@version=build(:version,end_lic: AmericanDate.yesterday.to_s)
			@version.save(:validate => false)
			expect(@access.reload.status).to eq "allowed"
			::Pack::PackWorker.perform_async(:expired)
			expect(@access.reload.status).to eq "expired"
			
		end
	end
		
	
		


end
