module Comments
  require 'main_spec_helper'
  describe Tagging do
    describe "::get_items" do
      before(:each) do
        @admin = create_admin
        @user = create(:user)
        @project = create_project
        @project2 = create_project
        @user_context = create(:context)
        @admin_context = create(:context)
        @comment = create(:comment,{attachable: @project,user: @user} )
        @comment2 = create(:comment,{attachable: @project2,user: @user} )
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
  end
end
