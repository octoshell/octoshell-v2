module Pack
	
	require "spec_helper"
	

	describe AmericanDate do
		
				

					describe "comparison with Date" do
						it "sddd" do
							

					 		am_date =  AmericanDate.new(2017,06,20) 
					 		date =  Date.new(1000,06,30) 

					 		expect(date.to_s >= am_date.to_s).to eq true
					 		expect(date <= am_date).to eq true

							
						
							

						end
					end
				

				end
		
	
		


end
