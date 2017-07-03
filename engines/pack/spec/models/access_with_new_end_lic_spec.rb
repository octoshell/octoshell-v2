module Pack
	
	require "spec_helper"
	

	describe "Pack::Access with date current" do
		['allowed','requested','denied',' expired']
		

			describe "acesses_actions_for_allowed_status" do
				before(:each) { @access = access_with_status(status: "allowed",end_lic: AmericanDate.yesterday.to_s, new_end_lic: AmericanDate.current.to_s,forever: false) }

				describe "date" do
					it "shows actions for  allowed status access without date" do
						expect( @access.actions ).to match_array ( ["denied","make_longer","deny_longer"] << 'edit_by_hand')
					end
				end


				describe "changes status  to denied" do
					it "changes status to denied and saves" do
						@access.action= "denied"
						
						expect( @access.save ).to  be(true)
						expect( @access.status ).to eq "denied"

					end
				end
				describe "allows longer" do
					it "makes longer and saves" do
						@access.action= "make_longer"
						Sidekiq::Worker.clear_all
					

						expect { @access.save! }.to change { ActionMailer::Base.deliveries.count }.by(2)

						expect( @access.status ).to eq "allowed"
						expect( @access.new_end_lic ).to eq nil
						date = Date.current
						am_date = AmericanDate.new( date.year,date.month,date.day )
						expect( @access.end_lic ).to eq am_date
						


					end
					it "denies longer and saves" do
						@access.action= "deny_longer"

						Sidekiq::Worker.clear_all
						expect { @access.save! }.to change { ActionMailer::Base.deliveries.count }.by(1)

						expect( @access.status ).to eq "expired"
						expect( @access.new_end_lic ).to eq nil
						date = Date.yesterday
						am_date = AmericanDate.new( date.year,date.month,date.day )
						expect( @access.end_lic ).to eq am_date
						

						

					end
				end
				
		


			
		end
	end
		


end
