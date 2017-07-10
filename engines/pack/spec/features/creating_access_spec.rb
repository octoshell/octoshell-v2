module Pack
	require "capybara_helper"
	

	
	describe "Requesting for access",type: :feature,js: true do 
		before(:each) do 
     		Group.default!
		end


				it "creates requested access for user" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					create_project(owner: user)
					# access = access_with_status(who: user,version: version)
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	
						select2 'proj_or_user','Пользователь'
						expect(page).to have_content('Пользователь')

						date = Date.current
						am_date = AmericanDate.new( date.year,date.month,date.day )

						 fill_in "access_end_lic",with: am_date.to_s 
						 click_button 'Отправить'
					end
					expect(page).to have_content('Действие с данным доступом успешно выполнено')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("requested")
					 expect(Access.first.created_by).to eq(user)
					 expect(Access.first.who).to eq(user)




				end

				it "creates requested access for project" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					project = create_project(owner: user)
					# access = access_with_status(who: user,version: version)
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	

						date = Date.current
						am_date = AmericanDate.new( date.year,date.month,date.day )

						 fill_in "access_end_lic",with: am_date.to_s 
						 click_button 'Отправить'
					end
					expect(page).to have_content('Действие с данным доступом успешно выполнено')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("requested")
					 expect(Access.first.created_by).to eq(user)
					 expect(Access.first.who).to eq(project)




				end

				it "creates requested access for project without date" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					project = create_project(owner: user)
					# access = access_with_status(who: user,version: version)
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	


						 choose 'access_forever_true'
						 click_button 'Отправить'
					end
					expect(page).to have_content('Действие с данным доступом успешно выполнено')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("requested")
					 expect(Access.first.end_lic).to eq nil
					 expect(Access.first.created_by).to eq(user)
					 expect(Access.first.who).to eq(project)




				end

				

				

	

				

		end
	end

		


