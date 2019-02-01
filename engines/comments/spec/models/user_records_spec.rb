# module Comments
#
# 	require 'main_spec_helper'
#
#
#
# 		describe "UserRecord::get_perrmission" do
#
# 			describe "@user2 has permissions for all projects" do
# 				before(:each) do
#
# 					@user = create(:user)
# 					@project = create_project
# 					@project2 = create_project
#
# 					Group.default!
# 					@user2 = create_support
# 					UserRecords.create_permission!(@user2.id,"Core::Project","read_ab")
#
# 					# @level = create(:level)
# 					# @level.new_level_group(Group.find_by!(name: 'support'),"read_ab" ).save!
# 					# @level.new_level_class('Core::Project').save!
#
# 				end
#
# 				it "1" do
#
# 			 		 q = UserRecords.has_permissions?([@project],@user2.id)
# 					expect(q).to eq true
#
# 				end
# 				it "2" do
# 			 		q = UserRecords.has_permissions?([@project,@project2],@user2.id)
# 					expect(q).to eq true
#
# 			 	end
# 			 	it "3" do
# 				 	q = UserRecords.has_permissions?(Core::Project.all.to_a,@user2.id)
# 					expect(q).to eq true
#
# 				 end
# 			end
# 			describe "@user2 has permissions for all projects with private" do
# 				before(:each) do
#
# 					@user = create(:user)
# 					@project = create_project
# 					@project2 = create_project
#
# 					Group.default!
# 					@user2 = create_support
# 					UserRecords.create_permission!(@user2.id,"Core::Project","read_ab",@project.id)
# 					UserRecords.create_permission!(@user2.id,"Core::Project","read_ab",@project2.id)
#
# 					# @level = create(:level)
# 					# @level.new_level_group(Group.find_by!(name: 'support'),"read_ab" ).save!
# 					# @level.new_level_class('Core::Project').save!
#
# 				end
#
# 				it "1" do
#
# 			 		 q = UserRecords.has_permissions?([@project],@user2.id)
# 					expect(q).to eq true
#
# 				end
#
#
# 				it "2" do
# 			 		q = UserRecords.has_permissions?([@project,@project2],@user2.id)
# 					expect(q).to eq true
#
# 			 	end
# 			 	it "3" do
# 				 	q = UserRecords.has_permissions?(Core::Project.all.to_a,@user2.id)
# 					expect(q).to eq true
#
# 				 end
#
# 				it "4" do
#
# 			 		 q = UserRecords.has_permissions?([@project],@user2.id,"read_ab")
# 					expect(q).to eq true
#
# 				end
# 				it "5" do
#
# 			 		 q = UserRecords.has_permissions?([@project],@user2.id,"create_ab")
# 					expect(q).to eq false
#
# 				end
#
# 			end
# 			describe "@user2 has permissions for first project" do
# 				before(:each) do
#
# 					@user = create(:user)
# 					@project = create_project
# 					@project2 = create_project
#
# 					Group.default!
# 					@user2 = create_support
# 					UserRecords.create_permission!(@user2.id,"Core::Project","read_ab",@project.id)
#
# 					# @level = create(:level)
# 					# @level.new_level_group(Group.find_by!(name: 'support'),"read_ab" ).save!
# 					# @level.new_level_class('Core::Project').save!
#
# 				end
#
# 				it "1" do
#
# 			 		 q = UserRecords.has_permissions? [@project],@user2.id
# 					expect(q).to eq true
#
# 				end
# 				it "2" do
# 			 		q = UserRecords.has_permissions? [@project,@project2],@user2.id
# 					expect(q).to eq false
#
# 			 	end
# 			 	it "3" do
# 				 	q = UserRecords.has_permissions? Core::Project.all.to_a,@user2.id
# 					expect(q).to eq false
#
# 				 end
# 			end
#
#
#
# 	end
#
#
# end
