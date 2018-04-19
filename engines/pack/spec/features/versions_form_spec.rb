module Pack
	require "capybara_helper"
	

	
	describe "Creating version",type: :feature,js: true do 
		before(:each) do 
     		Group.default!
			@admin = create_admin
			@package = create(:package)
			@cluster_1 = create(:cluster)
			# @cluster_2 = create(:cluster)
			@cat = create(:options_category)
			login_capybara(@admin)


		end

			["not_active","active","_destroy"].each do |cl_status|
				it "creates version with #{cl_status} status" do



					visit(new_admin_package_version_path(@package) )
					# puts Core::Cluster.count
					fill_in "version_name",with: 'name'
					fill_in "version_description",with: 'description'
					choose  "version_clustervers_attributes_0_action_#{cl_status}"
					click_button "options"				
					click_button "options"

					# jquery_regex
					# page.execute_script(<<-eo

					# $("input:regex(id,name_sel([0-9])*_to_s_auto)").first().click();
					# $("input:regex(id,version_version_options_attributes_([0-9])*_value").val('ffff');
					# console.log($("input:regex(id,version_version_options_attributes_([0-9])*_value").length)
					# console.log($("input:regex(id,version_version_options_attributes_([0-9])*_name").length)

					# $("input:regex(id,version_version_options_attributes_([0-9])*_name").eq(2).val('ffff');
					
					# eo
					# )
					# puts all('input'){ |el| el['id'] == 'version_name' }.count
					# all('input'){ |elem| puts  elem[:id] }
					all_with_con("textarea"){ |el|  el[:id].match /version_version_options_attributes_([0-9])*_value/ }.each do |el|
						fill_in el[:id].to_s,with: "description"
					end

					elem =  all_with_con("input"){ |el|  el[:id].match /version_version_options_attributes_([0-9])*_name/ }.second

					fill_in elem[:id], with: "name_1"
					

					choose all_with_con("input"){|el|  el[:id].match /name_sel([0-9])*_to_s_auto/ }.first[:id]

					all_with_con("span"){|el|  el[:id].match /select2-select([0-9])*-container/ }.first.click
					all_with_con("input"){|el|  el[:id].match /name_sel([0-9])*_to_s_auto/ }
					# page.driver.debug
					a = <<-eoruby
						$('li.select2-results__option').mouseup();
					eoruby
					page.execute_script(a)

					click_button("Сохранить")
					expect(page).to have_content('Версия')

					expect(Version.count).to eq(1)
					expect(VersionOption.count).to eq(2)
					if cl_status == '_destroy'
						expect(Version.first.clustervers.count).to eq(0)
						 
					elsif cl_status == 'active'
						expect(Version.first.clustervers.first.active).to eq(true)
					else
						expect(Version.first.clustervers.first.active).to eq(false)
					end


				end
			end

				

				

	

				

		end
	end

		


