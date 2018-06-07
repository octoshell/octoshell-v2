module Pack
  require "initial_create_helper"
  describe "Pack::Access requested access" do
    before(:each) do
      @version = create(:version)
      @user = create(:user)
      @organization = create(:organization)
      @project = create_project
      @project.members.create!(user: @user,
                              organization: @organization)



      @current_date = Date.current

      # @old_date = AmericanDate.new(date.year, date.month, date.day).to_s
      @old_date = AmericanDate.yesterday
      unless Support::Topic.find_by(name: I18n.t('integration.support_theme_name'))
        Support::Topic.create!(name: I18n.t('integration.support_theme_name'))
      end
    end

    it 'creates new requested access spec with date' do
      hash = { forever: 'false', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: AmericanDate.current.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
      @access = Access.first
      expect(@access.status).to eq 'requested'
      expect(@access.end_lic).to eq AmericanDate.current
    end

    it 'creates new requested access spec without date' do
      hash = { forever: 'true', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: @old_date.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
      @access = Access.first
      expect(@access.status).to eq 'requested'
      expect(@access.end_lic).to eq old_date
    end

    it 'creates new requested access spec with expired date' do
      hash = { forever: 'true', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: AmericanDate.current.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
      @access = Access.first
      expect(@access.status).to eq 'requested'
      expect(@access.end_lic).to eq nil
    end


  end



end
