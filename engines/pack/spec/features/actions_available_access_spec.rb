module Pack
	require "capybara_helper"
	

	
	describe "Actions available",type: :feature,js: true do 
		before(:each) do 
     		Group.default!
		end


				it "requests new_end_lic date for allowed access" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					create_project(owner: user)
					access = access_with_status(who: user,version: version,status: 'allowed',end_lic: Date.current.to_s)
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	
						select2 'proj_or_user','Пользователь'
						date = Date.tomorrow
						am_date = AmericanDate.new( date.year,date.month,date.day )

						fill_in "access_new_end_lic",with: am_date.to_s 
						expect(page).to have_content('Пользователь')
						click_button 'Отправить'

					end
					expect(page).to have_content('Действие с данным доступом успешно выполнено')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("allowed")
					 expect(Access.first.who).to eq(user)




				end

				it "requests new_end_lic date for allowed access" do
					user = create(:user)
					create_support
					package = create(:package)
					version = create(:version,package: package)
					version2 = create(:version,package: package)
					create_project(owner: user)
					access = access_with_status_without_validation(who: user,version: version,status: 'expired',end_lic: Date.yesterday.to_s)
					 login_capybara(user)
					 visit(package_path(package))
					 find('h3', text: 'Версии')

					 find("button[vers_id=#{"'" + version.id.to_s + "'"}]", text: 'послать заявку').click 
					 find("button[vers_id=#{"'" + version2.id.to_s + "'"}]", text: 'послать заявку').click 

					within("div.select_for_access[vers_id=#{"'" + version.id.to_s + "'"}]") do	
						select2 'proj_or_user','Пользователь'
						date = Date.tomorrow
						am_date = AmericanDate.new( date.year,date.month,date.day )

						fill_in "access_new_end_lic",with: am_date.to_s 
						expect(page).to have_content('Пользователь')
						click_button 'Отправить'


					end
					expect(page).to have_content('Действие с данным доступом успешно выполнено')

					 expect(Access.count).to eq(1)
					 expect(Access.first.status).to eq("expired")
					 expect(Access.first.who).to eq(user)




				end

				
		end
	end

		


