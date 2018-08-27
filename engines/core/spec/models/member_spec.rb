    module Core
      require ""
      describe Member do
        describe "automerge" do
          before(:each) do
            @organization = create(:organization)
            @department1 = create(:organization_department,organization: @organization)
            @department2 = create(:organization_department,organization: @organization)

            @user = create(:user)
            @user_with_many_employments = create(:user)

            @department1.employments.create!(user: @user)
            @department1.employments.create!(organization: @organization, user: @user_with_many_employments)
            @department2.employments.create!(organization: @organization, user: @user_with_many_employments)
            @project = create_project
            @project.members.create!(user: @user,
                                    organization: @organization)
            @project.members.create!(user: @user_with_many_employments,
                                    organization: @organization)

          end

          it "::can_not_automerged" do
            expect(Member.can_not_be_automerged(@department1).to_a.map(&:user)).to match_array [@user_with_many_employments]
          end
          it "::can_automerged" do
            expect(Member.can_be_automerged(@department1).to_a.map(&:user)).to match_array [@user]
          end
        end
      end
    end
