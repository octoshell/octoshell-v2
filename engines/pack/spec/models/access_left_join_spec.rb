# module Pack
	
# 	require "spec_helper"
	

# 	describe "Pack::Access with date current" do
		
# 		before(:each) { @access = access_with_status(status: key,end_lic: AmericanDate.today.to_s,forever: true) }

				
# 				 	it "edits and save  correctly" do
				 		
# 				 		@access.update!( end_lic: AmericanDate.yesterday.to_s, forever: false)
# 				 		date = Date.yesterday
# 				 		expect( @access.end_lic.to_s ).to  eq(  AmericanDate.new(date.year ,date.month, date.day).to_s )
# 				 		expect( @access.save ).to  be true
# 				 		if key == "allowed"
				 			
# 				 			expect(@access.status).to eq "expired"
# 				 		else
# 				 			expect(@access.status).to eq key
# 				 		end
				 		
							
# 				 	end

				
# 	end
		


# end
