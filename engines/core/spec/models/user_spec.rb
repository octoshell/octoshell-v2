module Core
  require 'main_spec_helper'
  describe User do
    describe "#suspend_all_accounts" do
      it "synchronizes and block members" do
        @project = create(:project, state: 'active')
        @project.members.each do |m|
          m.project_access_state = 'allowed'
          m.save!
        end
        @user = @project.owner
        expect(@user.accounts.map(&:project_access_state)).to eq ['allowed']
        tried = false
        allow_any_instance_of(Core::Project).to receive(:synchronize!) do
          tried = true
        end
        @user.block!
        @user.reload
        expect(@user.accounts.map(&:project_access_state)).to eq ['suspended']
        expect(tried).to eq true
      end
    end
  end
end
