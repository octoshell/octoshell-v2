module Pack
	
	require "spec_helper"
	

	describe AccessesController,type: :controller do
		routes { Pack::Engine.routes }
		describe "#form" do 
			Access.aasm.states.map(&:to_s).each do |status|
				it "renders form for access with #{status}" do
					user = create(:user)
					version = create(:version)
					access = access_with_status(who: user,version: version)
					login_user(user)
					xhr :get, :form,{proj_or_user: 'user',version_id: version.id}
					expect(assigns(:access)).to eq access

				end


			end
			it "renders form for new access" do
				user = create(:user)
				version = create(:version)
				login_user(user)
				xhr :get, :form,{proj_or_user: 'user',version_id: version.id}
			end

		end
	end
		
		


end
