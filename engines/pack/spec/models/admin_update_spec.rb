module Pack
  require 'main_spec_helper'
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
      unless Support::Topic.find_by(name: I18n.t('integration.support_theme_name'))
        Support::Topic.create!(name: I18n.t('integration.support_theme_name'))
      end
    end

    %w[deleted requested allowed denied].each do |a|
      it "changes date to nil  for #{a}" do
        @access = access_with_status(status: a, end_lic: @current_date)
        @access.admin_update(@admin, forever: 'true',
                                     status: a,
                                     end_lic: @current_date.to_s,
                                     lock_version: @access.lock_version.to_s)
        expect(@access.end_lic).to eq nil
      end

      it "changes date to current  for #{a}" do
        @access = access_with_status(status: a, end_lic: nil)
        @access.admin_update(@admin, forever: 'false',
                                     status: a,
                                     end_lic: @current_date.to_s,
                                     lock_version: @access.lock_version.to_s)
        expect(@access.end_lic).to eq @current_date
      end

      it "changes date to current  for #{a}" do
        @access = access_with_status(status: a, end_lic: nil)
        @access.admin_update(@admin, forever: 'false',
                                     status: a,
                                     end_lic: @old_date.to_s,
                                     lock_version: @access.lock_version.to_s)
        expect(@access.end_lic).to eq @old_date
        if a == 'allowed'
          expect(@access.status).to eq 'expired'
        end
      end
    end

    it "changes date to current  for expired status" do
      @access = access_with_status(status: 'allowed', end_lic: @old_date)
      expect(@access.status).to eq 'expired'
      @access.admin_update(@admin, forever: 'false',
                                   status: 'expired',
                                   end_lic: @current_date.to_s,
                                   lock_version: @access.lock_version.to_s)
      expect(@access.end_lic).to eq @current_date
      expect(@access.status).to eq 'allowed'
    end

  end
end
