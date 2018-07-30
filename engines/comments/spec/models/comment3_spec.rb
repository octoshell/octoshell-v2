module Comments
  require "initial_create_helper"
  describe Comment do
    describe "::read_items items without context" do
      before(:each) do
        Group.default!
        @user = create_admin
        @user2 = create_support
        @project = create_project
        @project2 = create_project
      end
      it "retrieves comments 1" do
        @comment2 = create(:comment, attachable: @project2, user: @user)
        @comment3 = create(:comment, attachable: @project2, user: @user2)
        @comment4 = create(:comment, context: create(:context),attachable: @project2, user: @user2)
        hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:read_ab])
        @rel = Comment.read_items(hash, @user.id).to_a
        expect(Comment.read_items(hash, @user.id).to_a).to match_array [@comment2, @comment3]
          expect(@rel.detect{|c| c.id = @comment3.id}.can_update?(@user.id)).to eq false

      end

      it "retrieves comments 2" do
        @comment2 = create(:comment, attachable: @project2, user: @user)
        @comment3 = create(:comment, attachable: @project2, user: @user2)
        @comment4 = create(:comment, context: create(:context),attachable: @project2, user: @user2)
        hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:read_ab])
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:update_ab])
        @rel = Comment.read_items(hash, @user.id).to_a
        expect(Comment.read_items(hash, @user.id).to_a).to match_array [@comment2, @comment3]
          expect(@rel.detect{|c| c.id = @comment3.id}.can_update?(@user.id)).to eq true

      end
      it "retrieves comments 3" do
        @comment2 = create(:comment, attachable: @project2, user: @user)
        @comment3 = create(:comment, attachable: @project2, user: @user2)
        @comment4 = create(:comment, context: create(:context),attachable: @project2, user: @user2)
        hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:read_ab])
        GroupClass.create!(allow: true,
                           class_name: 'Core::Project',
                           type_ab: GroupClass.type_abs[:update_ab])
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           group: Group.find_by!(name: 'authorized'),
                           type_ab: GroupClass.type_abs[:update_ab])
        GroupClass.create!(allow: false,
                           class_name: 'Core::Project',
                           group: Group.find_by!(name: 'superadmins'),
                           type_ab: GroupClass.type_abs[:update_ab])


        @rel = Comment.read_items(hash, @user.id).to_a
        expect(Comment.read_items(hash, @user.id).to_a).to match_array [@comment2, @comment3]
        expect(@rel.detect{|c| c.id = @comment3.id}.can_update?(@user.id)).to eq false

      end



      #
      # it "user can update comment" do
      #   @context = create :context
      #   @comment2 = create(:comment, attachable: @project2, user: @user)
      #   hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
      #   ContextGroup.create!(context: @context,
      #                        group: Group.find_by!(name: 'superadmins'),
      #                        type_ab: ContextGroup.type_abs[:read_ab]  )
      #  ContextGroup.create!(context: @context,
      #                       group: Group.find_by!(name: 'superadmins'),
      #                       type_ab: ContextGroup.type_abs[:update_ab]  )
      #
      #   expect(Comment.read_items(hash, @user.id).first.can_update?(@user.id)).to eq true
      # end
      #
      # it "user can't update comment" do
      #   @context = create :context
      #   @user2 = create_admin
      #   @comment2 = create(:comment,context: @context, attachable: @project2, user: @user)
      #   hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
      #   ContextGroup.create!(context: @context,
      #                        group: Group.find_by!(name: 'superadmins'),
      #                        type_ab: :read_ab  )
      #   expect(Comment.read_items(hash, @user.id).first.can_update?(@user2.id)).to eq false
      # end


    end
  end
end
