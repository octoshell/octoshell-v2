module Pack
	require "capybara_helper"
	

	
	describe "No actions available",type: :feature,js: true do 
		before(:each) do 
     		Group.default!
		end


				it "renders action for  deleted access" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					create_project(owner: user)
					access = access_with_status(who: user,version: version,status: 'deleted')
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	
						select2 'proj_or_user','Пользователь'
						expect(page).to have_content('Пользователь')

					end
					expect(page).to have_content('Ваш доступ к данной версии удален')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("deleted")
					 expect(Access.first.who).to eq(user)




				end
				it "renders action for  allowed access without date" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					create_project(owner: user)
					access = access_with_status(who: user,version: version,status: 'allowed',forever: 'true')
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	
						select2 'proj_or_user','Пользователь'
						expect(page).to have_content('Пользователь')

					end
					expect(page).to have_content('Вы не можете ничего более запросить')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("allowed")
					 expect(Access.first.who).to eq(user)




				end

				
				

				

	

				

		end
	end

		


