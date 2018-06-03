# module Pack
	
# 	require "no_cleaner_helper"
# 	#require "spec_helper"
# 	require 'benchmark'
	
# describe PackagesController,type: :controller do
# 	routes { Pack::Engine.routes }
# 	describe "left join time testing" do
		
# 		it "user has not got access, associated with package's version)" do

# 			puts Access.count
# 			puts Core::Member.count
# 			user = User.first
# 			login_user(user)

# 			get :index,{q: {type: 'versions',user_access: user.id}}

# 			Version.preload_and_to_a(user.id,assigns(:records))

# 			expect(assigns(:records).count).to eq 15

							
			
# 		end
			
	
# 	end
# end
# end
