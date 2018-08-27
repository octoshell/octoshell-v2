# module Comments
#   require ""
#   describe Level do
#     describe "::create_permission_level" do
#       before(:each) do
#         Group.default!
#         @user = create_admin
#         @project = create_project
#         @project2 = create_project
#       end
#       it "doesn't retrieve restricted comments" do
#
#         expect(Level
#           .create_permission_level('Core::Project', @project.id, @user.id).to_a)
#           .to match_array [@user_level, @level, @intermediate_level]
#
#       end
#     end
#   end
# end
