module Comments
  require ""
  describe Permissions do
    describe "::create_permissions" do
      before(:each) do
        Group.default!
        @user = create_admin
        @user2 = create_support
        @project = create_project
        @project2 = create_project
      end
      it "retrieves comments 1" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_ab])
        expect(Permissions.create_permissions(hash)).to eq true
      end

      it "retrieves comments 2" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
        expect(Permissions.create_permissions(hash)).to eq :create_with_context
      end

      it "doesn't retrieve comments 3" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        expect(Permissions.create_permissions(hash)).to eq false
      end

      it "doesn't retrieve comments 4" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
        expect(Permissions.create_permissions(hash)).to eq false
      end

      it "retrieves comments 5" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
       GroupClass.create!(allow: true,
                          group: @user.groups.first,
                          class_name: 'Core::Project',
                          type_ab: GroupClass.type_abs[:create_with_context_ab])

        expect(Permissions.create_permissions(hash)).to eq :create_with_context
      end

      it "retrieves comments 5,5" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
       GroupClass.create!(allow: true,
                          group: @user.groups.first,
                          obj_id: [@project.id],
                          class_name: 'Core::Project',
                          type_ab: GroupClass.type_abs[:create_with_context_ab])

        expect(Permissions.create_permissions(hash)).to eq :create_with_context
      end


      it "retrieves comments 6" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
       GroupClass.create!(allow: true,
                          group: @user.groups.first,
                          class_name: 'Core::Project',
                          type_ab: GroupClass.type_abs[:create_with_context_ab])

        expect(Permissions.create_permissions(hash)).to eq :create_with_context
      end

      it "retrieves comments 7" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
       GroupClass.create!(allow: false,
                          group: @user.groups.first,
                          class_name: 'Core::Project',
                          type_ab: GroupClass.type_abs[:create_ab])

        expect(Permissions.create_permissions(hash)).to eq :create_with_context
      end

      it "doesn't retrieve comments 8" do
        hash = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
       @user.groups.each do |group|
         GroupClass.create!(allow: false,
                            group: group,
                            class_name: 'Core::Project',
                            type_ab: GroupClass.type_abs[:create_with_context_ab])
       end
        expect(Permissions.create_permissions(hash)).to eq false
      end

      it "doesn't retrieve comments 9" do
        hash1 = { class_name: 'Core::Project', ids: [@project.id],user: @user}
        hash2 = { class_name: 'Core::Project', ids: [@project2.id],user: @user}
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
        GroupClass.create!(allow: true,
                           group: @user.groups.first,
                           obj_id: @project2.id,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:create_with_context_ab])
        expect(Permissions.create_permissions(hash1)).to eq false
        expect(Permissions.create_permissions(hash2)).to eq :create_with_context
      end
    end
  end
end
