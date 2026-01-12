module Comments
  require 'main_spec_helper'
  describe Comment do
    describe '::read_items items without context' do
      before(:each) do
        Group.default!
        @user = create_admin
        @user2 = create_support
        @user3 = create_admin
        @user4 = create_admin
        @other_user = create_admin
        @project = create_project
        @tag1 = create(:tag, name: 'faced problems with the GROMACS application package')
        @tag2 = create(:tag)
        @tagging1 = create(:tagging, tag: @tag1, attachable: @user3, user: @user)
        @tagging2 = create(:tagging, tag: @tag1, attachable: @user4, user: @user)
        @tagging3 = create(:tagging, attachable: @user3, user: @user)
        @tagging4 = create(:tagging, tag: @tag1, attachable: @project, user: @user)
        @tagging_other = create(:tagging, tag: @tag2, attachable: @other_user, user: @user)
      end
      it 'retrieves all Gromacs tags' do
        rel = Comments::Tagging.joins(:tag)
                               .where(comments_tags: { name: 'faced problems with the GROMACS application package' })
                               .get_items(User.all)
        emails = rel.map(&:attachable).map(&:email)
        expect(emails).to match_array [@user3.email, @user4.email]
      end

      it 'retrieves specific Gromac tag' do
        rel = Comments::Tagging.joins(:tag)
                               .where(comments_tags: { name: 'faced problems with the GROMACS application package' })
                               .get_items(User.where(email: @user3.email))
        emails = rel.map(&:attachable).map(&:email)
        expect(emails).to match_array [@user3.email]
      end
    end
  end
end
