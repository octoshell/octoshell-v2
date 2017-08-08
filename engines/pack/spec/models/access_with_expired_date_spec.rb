module Pack
	
	require "spec_helper"
	

	describe "Pack::Access without date" do
		
		{"requested" => [ 'denied' ],"allowed" => ["denied"],"denied" => ['expired'] }.each do |key,value| 

			describe "acesses_actions_for_#{key}_status" do
				before(:each) { @access = access_with_status(status: key,end_lic: AmericanDate.yesterday.to_s,forever: false) }

				describe "date" do
					it "shows actions for  requested status access without date" do
						expect( @access.actions ).to match_array (value << 'edit_by_hand')
					end
				end

				(value ).each do |a|

					describe "changes status  to #{a}" do
						it "saves correctly" do

							@access.action= a	
							expect( @access.save ).to  be(true)
							( expect( @access.status ).to eq a  ) unless key == 'allowed'
							

						end
						
					end
				end
				describe "edits by hand" do
				 	it "edits and save  correctly with end_lic" do
				 		
				 		@access.update!( end_lic: AmericanDate.current.to_s, forever: false)
				 		date = Date.current
				 		expect( @access.end_lic.to_s ).to  eq(  AmericanDate.new(date.year ,date.month, date.day).to_s )
				 		expect( @access.save ).to  be true
				 		if key == "expired"
				 			
				 			expect(@access.status).to eq "allowed"
				 		else
				 			expect(@access.status).to eq key
				 		end
				 		
							
				 	end

				end	
				describe "edits by hand" do
				 	it "edits and save  correctly without end_lic" do
				 		
				 		@access.update!(  forever: true)
				 		date = Date.current
				 		expect( @access.save ).to  be true
				 		expect( @access.end_lic ).to  eq nil

				 		if key == "expired"
				 			
				 			expect(@access.status).to eq "allowed"
				 		else
				 			expect(@access.status).to eq key
				 		end
				 		
							
				 	end

				end	



			end
		end
	end
		


end
