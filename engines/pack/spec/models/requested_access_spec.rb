module Pack
  require "initial_create_helper"
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
      @old_usual_date = Date.yesterday
      @old_date = AmericanDate.new(@old_usual_date.year, @old_usual_date.month, @old_usual_date.day)
      unless Support::Topic.find_by(name: I18n.t('integration.support_theme_name'))
        Support::Topic.create!(name: I18n.t('integration.support_theme_name'))
      end
    end

    it 'creates new requested access spec with date' do
      hash = { forever: 'false', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: AmericanDate.current.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
              .and change { Support::Ticket.count }.by(1)

      @access = Access.first
      expect(@access.status).to eq 'requested'
      expect(@access.end_lic).to eq AmericanDate.current
      expect(@access.actions).to match_array %w[requested allowed denied]
      expect{@access.admin_update(@admin, forever: 'true',
                                          status: 'allowed',
                                          end_lic: AmericanDate.current.to_s,
                                          lock_version: @access.lock_version.to_s)}
                    .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(@access.status).to eq 'allowed'
      expect(@access.end_lic).to eq nil
      expect(@access.allowed_by).to eq @admin

    end

    it 'changes status to denied' do
      hash = { forever: 'false', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: AmericanDate.current.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
              .and change { Support::Ticket.count }.by(1)

      @access = Access.first

      @access.admin_update(@admin, forever: 'false',
                                   status: 'denied',
                                   end_lic: @old_date.to_s,
                                   lock_version: @access.lock_version.to_s)
      expect(@access.status).to eq 'denied'
      expect(@access.end_lic).to eq @old_date
    end

    it 'creates new requested access spec without date' do
      hash = { forever: 'true', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: AmericanDate.current.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
               .and change { Support::Ticket.count }.by(1)
      @access = Access.first
      expect(@access.status).to eq 'requested'
      expect(@access.actions).to match_array %w[requested allowed denied]
      expect(@access.end_lic).to eq nil
      Sidekiq::Worker.clear_all
      expect{@access.admin_update(@admin, forever: 'false',
                                          status: 'allowed',
                                          end_lic: AmericanDate.current.to_s,
                                          lock_version: @access.lock_version.to_s)}
                    .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(@access.status).to eq 'allowed'
      expect(@access.end_lic).to eq AmericanDate.current
      expect(@access.allowed_by).to eq @admin
    end



    it 'creates new requested access spec with expired date' do
      hash = { forever: 'false', status: 'new', type: @project.id.to_s,
               version_id: @version.id, end_lic: @old_date.to_s}

      expect { Access.user_update(hash, @user.id) }.to change { Access.count }.from(0).to(1)
              .and change { Support::Ticket.count }.by(1)
      @access = Access.first
      expect(@access.status).to eq 'requested'
      expect(@access.end_lic).to eq @old_date
      expect(@access.actions).to match_array %w[requested expired denied]
      expect{@access.admin_update(@admin, forever: 'false',
                                          status: 'expired',
                                          end_lic: @old_date.to_s,
                                          lock_version: @access.lock_version.to_s)}
                    .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(@access.status).to eq 'expired'
      expect(@access.end_lic).to eq @old_date
      expect(@access.allowed_by).to eq nil
    end
  end
end
