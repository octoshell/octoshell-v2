module Pack
	require "spec_helper"
	describe PackagesController,type: :controller do
		routes { Pack::Engine.routes }
		describe "#index" do
			describe "options_for_select" do
				it "1" do
					user = create(:user)
					project = create_project(owner: user)
					login_user(user)
					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:options_for_select)).to eq( [[I18n.t('project') + ' ' + project.title,project.id],[I18n.t('user'),"user"] ] )
					expect(response).to render_template("index")
				end
				it "2" do


					user = create(:user)
					project = create_project
					project.members.create!(user: user )

					login_user(user)

					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:options_for_select)).to eq( [[I18n.t('user'),"user"] ] )
					expect(response).to render_template("index")
				end

				it "3" do


					user = create(:user)
					project = create_project

					login_user(user)

					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:options_for_select)).to eq( [[I18n.t('user'),"user"] ] )
					expect(response).to render_template("index")
				end



			end
			describe "shows versions with {user_access: current_user.id}" do
				it "user has not got access, associated with  version" do


					user = create(:user)
					package = create(:package)
					create(:version,package: package)
					login_user(user)

					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:records)).to eq( [] )
					expect(response).to render_template("index")
				end
				it "user has  got access, associated with  version" do


					user = create(:user)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: user,version: version} )

					login_user(user)

					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:records)).to eq( [version] )
					expect(response).to render_template("index")
				end

				it "only another user has  got  access, associated with  version" do
					user = create(:user)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {version: version} )
					login_user(user)

					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:records)).to eq( [] )
					expect(response).to render_template("index")
				end

				it "user's project  has  got  access, associated with  version" do
					owner = create(:user)
					project = create_project(owner: owner)
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: project, version: version} )
					user = create(:user)
					login_user(user)
					project.members.create!(user: user )

					get :index,{q: {type: 'versions',user_access: user.id}}
					expect(assigns(:records)).to eq( [version] )
					expect(response).to render_template("index")
				end
				it "another project  has  got  access, associated with  version" do
					owner = create(:user)
					project = create_project(owner: owner)
					project_with_access = create_project
					package = create(:package)
					version = create(:version,package: package)
					access_with_status( {who: project_with_access, version: version} )
					user = create(:user)
					login_user(user)
					project.members.create!(user: user )

					get :index,{q: {type: 'versions',user_access: user.id}}
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

					get :index,{q: {type: 'versions',user_access: user.id,accesses_who_type_in: "allowed"}}
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
					get :index,{q: {type: 'versions',user_access: user.id,accesses_status_in: "allowed"}}
					expect(assigns(:records)).to eq( [version] )
					expect(response).to render_template("index")


				end



			end

			it "shows all versions" do
				user = create(:user)
				package = create(:package)
				version = create(:version,package: package)
				login_user(user)

				get :index,{q:{type: "versions",user_access: ""}}
				expect(assigns(:records)).to eq( [version] )
				expect(response).to render_template("index")
			end
			it "doesn't show service versions without access" do
				user = create(:user)
				package = create(:package)
				version = create(:version,{package: package,service: true})
				package2 = create(:package)
				version2 = create(:version,{package: package,service: true})
				access_with_status(version: version2,who: user)

				login_user(user)

				get :index,{q:{type: "versions",user_access: ""}}
				expect(assigns(:records)).to eq( [] )
				expect(response).to render_template("index")
			end

			it  "Show service versions with access" do
				user = create(:user)
				package = create(:package)
				version = create(:version,{package: package,service: true})
				access_with_status(version: version,who: user,status: "allowed")

				login_user(user)

				get :index,{q:{type: "versions",user_access: ""}}
				expect(assigns(:records)).to eq( [version] )
				expect(response).to render_template("index")
			end




		end
	end




end
