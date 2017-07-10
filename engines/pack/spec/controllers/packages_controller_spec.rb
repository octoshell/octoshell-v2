module Pack
	
	require "spec_helper"
	

	describe PackagesController,type: :controller do
		routes { Pack::Engine.routes }
		describe "#index" do 
			describe "shows packages with {user_access: current_user.id}" do
				it "user has not got access, associated with package's version)" do

					
					user = create(:user)
					package = create(:package)
					create(:version,package: package)
					login_user(user)

					get :index
					expect(assigns(:records)).to eq( [] )
					expect(response).to render_template("index")
				end
				it "user has  got access, associated with package's version)" do

					
					user = create(:user)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: user,version: version} )
		
					login_user(user)

					get :index
					expect(assigns(:records)).to eq( [package] )
					expect(response).to render_template("index")
				end

				it "only another user has  got  access, associated with package's version)" do
					user = create(:user)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {version: version} )
					login_user(user)

					get :index
					expect(assigns(:records)).to eq( [] )
					expect(response).to render_template("index")
				end

				it "user's project  has  got  access, associated with package's version)" do
					owner = create(:user)
					project = create_project(owner: owner)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: project, version: version} )
					user = create(:user)
					login_user(user)
					project.members.create!(user: user )

					get :index
					expect(assigns(:records)).to eq( [package] )
					expect(response).to render_template("index")
				end
				it "another project  has  got  access, associated with package's version)" do
					owner = create(:user)
					project = create_project(owner: owner)
					project_with_access = create_project
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: project_with_access, version: version} )
					user = create(:user)
					login_user(user)
					project.members.create!(user: user )

					get :index
					expect(assigns(:records)).to eq( [] )
					expect(response).to render_template("index")

					
				end
				it "user's project  has  got   requested access, associated with package's version, but searches  allowed access" do
					owner = create(:user)
					project = create_project(owner: owner)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: project, version: version} )
					user = create(:user)
					login_user(user)
					project.members.create!(user: user )

					get :index,{q: {type: 'packages',user_access: user.id,accesses_who_type_in: "allowed"}}
					expect(assigns(:records)).to eq( [] )
					expect(response).to render_template("index")
				
					
				end

				it "user's project  has  got   allowed access, associated with package's version, but searches  allowed access" do
					owner = create(:user)
					project = create_project(owner: owner)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {status: "allowed",forever: "true", who: project, version: version} )
					user = create(:user)
					project.members.create!(user: user )
					login_user(user)

					get :index,{q: {type: 'packages',user_access: user.id,accesses_status_in: "allowed"}}
					expect(assigns(:records)).to eq( [package] )
					expect(response).to render_template("index")
				
					
				end

				it "user's group  has  got   allowed access, associated with package's version, but searches  allowed access" do
					
					package = create(:package)
					version = create(:version,package: package)
					Group.default!
					user = create_admin
					access_with_status( {status: "allowed",forever: "true", who: user , version: version} )
					login_user(user)

					get :index
					expect(assigns(:records)).to eq( [package] )
					expect(response).to render_template("index")
				
					
				end



			end

			it "shows all packages" do

			
				
				user = create(:user)
				package = create(:package)
				create(:version,package: package)
				login_user(user)

				get :index,{q:{type: "packages",user_access: ""}}
				expect(assigns(:records)).to eq( [package] )
				expect(response).to render_template("index")
			end
		end

		 
	end
		
		


end
