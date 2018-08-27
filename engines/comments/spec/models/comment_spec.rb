module Comments
  require ""
  describe Comment do
    describe "::get_items" do
      before(:each) do
        @user = create(:user)
        @project = create_project
        @project2 = create_project
        @comment = create(:comment,attachable: @project,user: @user  )
        @comment2 = create(:comment, attachable:@project2, user: @user )
         create(:comment,{attachable: create_project,user: @user} )
      end
      it "gets comments for relation arg " do
        expect(Comment.get_items(Core::Project.limit(1))).to eq [@comment]
      end
      it "gets comments for array  arg " do
        expect(Comment.get_items([@project, @project2])).to eq [@comment, @comment2]
      end
      it "gets comments for model  arg " do
        expect(Comment.get_items(@project)).to eq [@comment]
      end
      it "gets comments for hash  arg " do
        expect(Comment.get_items(class_name: 'Core::Project',
                                 ids: [@comment.attachable_id])).to eq [@comment]
      end
    end
    describe "::read_items" do
      before(:each) do
        Group.default!
        @user = create_admin
        @user2 = create_support
        @project = create_project
        @project2 = create_project
        @comment = create(:comment, attachable: @project, user: @user)

      end
      it "doesn't retrieve restricted comments" do
        hash = { class_name: 'Core::Project', ids: [@comment.attachable_id] }
        expect(Comment.read_items(hash, @user.id).to_a).to eq []
      end

      it "retrieve comments" do
        @context = create :context
        @context2 = create :context
        @comment2 = create(:comment, context: @context, attachable: @project2, user: @user)
        @comment3 = create(:comment, context: @context2, attachable: @project2, user: @user2)
        hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
        ContextGroup.create!(context: @context,
                             group: Group.find_by!(name: 'superadmins'),
                             type_ab: ContextGroup.type_abs[:read_ab]  )
        expect(Comment.read_items(hash, @user.id).to_a).to eq [@comment2]
      end

      it "user can update comment" do
        @context = create :context
        @comment2 = create(:comment, context: @context, attachable: @project2, user: @user)
        hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
        ContextGroup.create!(context: @context,
                             group: Group.find_by!(name: 'superadmins'),
                             type_ab: ContextGroup.type_abs[:read_ab])
       ContextGroup.create!(context: @context,
                            group: Group.find_by!(name: 'superadmins'),
                            type_ab: ContextGroup.type_abs[:update_ab]  )

        expect(Comment.read_items(hash, @user.id).first.can_update?(@user.id)).to eq true
      end

      it "user can't update comment" do
        @context = create :context
        @user2 = create_admin
        @comment2 = create(:comment,context: @context, attachable: @project2, user: @user)
        hash = { class_name: 'Core::Project', ids: [@comment2.attachable_id] }
        ContextGroup.create!(context: @context,
                             group: Group.find_by!(name: 'superadmins'),
                             type_ab: :read_ab  )
        expect(Comment.read_items(hash, @user.id).first.can_update?(@user2.id)).to eq false
      end


    end
  end
end
