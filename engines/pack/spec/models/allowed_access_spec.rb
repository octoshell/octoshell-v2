module Pack
  require ""
  describe "Pack::Access requested access" do
    before(:each) do
      @version = create(:version)
      @user = create(:user)
      Group.default!
      @admin = create_admin
      @organization = create(:organization)
      @project = create_project
      @project.members.create!(user: @user,
                              organization: @organization)
      @current_date = Date.current
      @old_date = Date.yesterday
      @tomorrow_date = Date.current + 1
      @access = access_with_status(version: @version, who: @user,
                                   status: 'allowed', end_lic: Date.current.to_s,
                                   created_by: @user, allowed_by: @admin)
    end

    it 'creates new request with date for allowed access(delete_request false) and admin gives user access forever' do
      hash = { new_end_lic_forever: 'false', status: 'allowed', type: 'user',
               version_id: @version.id, new_end_lic: @tomorrow_date.to_s}
      Access.user_update(hash, @user.id)
      @access = Access.first
      expect(@access.status).to eq 'allowed'
      expect(@access.new_end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false

      expect(@access.actions).to match_array %w[allowed denied deny_longer make_longer]
      @access.admin_update(@admin, forever: 'true',
                                    status: 'allowed',
                                    end_lic: Date.current.to_s,
                                    lock_version: @access.lock_version.to_s,
                                    delete_request: 'false')
      expect(@access.status).to eq 'allowed'
      expect(@access.end_lic).to eq nil
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.new_end_lic).to eq nil
    end

    it 'creates new request with date for allowed access (delete_request true)' do
      hash = { new_end_lic_forever: 'false', status: 'allowed', type: 'user',
               version_id: @version.id, new_end_lic: @tomorrow_date.to_s}
      Access.user_update(hash, @user.id)
      @access = Access.first
      expect(@access.status).to eq 'allowed'
      expect(@access.new_end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.actions).to match_array %w[allowed denied deny_longer make_longer]
      @access.admin_update(@admin, forever: 'false',
                                    status: 'allowed',
                                    end_lic: @tomorrow_date,
                                    lock_version: @access.lock_version.to_s,
                                    delete_request: 'true')
      expect(@access.status).to eq 'allowed'
      expect(@access.end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.new_end_lic).to eq nil
    end

    it 'makes longer' do
      hash = { new_end_lic_forever: 'false', status: 'allowed', type: 'user',
               version_id: @version.id, new_end_lic: @tomorrow_date.to_s}
      Access.user_update(hash, @user.id)
      @access = Access.first
      expect(@access.status).to eq 'allowed'
      expect(@access.new_end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.actions).to match_array %w[allowed denied deny_longer make_longer]
      @access.admin_update(@admin, forever: 'false',
                                    status: 'make_longer',
                                    end_lic: Date.current.to_s,
                                    lock_version: @access.lock_version.to_s,
                                    delete_request: 'true')
      expect(@access.status).to eq 'allowed'
      expect(@access.end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.new_end_lic).to eq nil
    end

    it 'denies longer' do
      hash = { new_end_lic_forever: 'false', status: 'allowed', type: 'user',
               version_id: @version.id, new_end_lic: @tomorrow_date.to_s}
      Access.user_update(hash, @user.id)
      @access = Access.first
      expect(@access.status).to eq 'allowed'
      expect(@access.new_end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.actions).to match_array %w[allowed denied deny_longer make_longer]
      @access.admin_update(@admin, forever: 'false',
                                    status: 'deny_longer',
                                    end_lic: @tomorrow_date.to_s,
                                    lock_version: @access.lock_version.to_s,
                                    delete_request: 'true')
      expect(@access.status).to eq 'allowed'
      expect(@access.end_lic).to eq Date.current
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.new_end_lic).to eq nil
    end



    it 'creates new request with date for allowed access + deny access' do
      hash = { new_end_lic_forever: 'false', status: 'allowed', type: 'user',
               version_id: @version.id, new_end_lic: @tomorrow_date.to_s}
      Access.user_update(hash, @user.id)
      @access = Access.first
      expect(@access.status).to eq 'allowed'
      expect(@access.new_end_lic).to eq @tomorrow_date
      expect(@access.new_end_lic_forever).to eq false

      expect(@access.actions).to match_array %w[allowed denied deny_longer make_longer]
      @access.admin_update(@admin, forever: 'false',
                                          status: 'denied',
                                          end_lic: Date.current.to_s,
                                          lock_version: @access.lock_version.to_s,
                                          delete_request: 'false')
      expect(@access.status).to eq 'denied'
      expect(@access.end_lic).to eq Date.current
      expect(@access.new_end_lic_forever).to eq false
      expect(@access.new_end_lic).to eq nil
    end
  end
end
