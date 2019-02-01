module Pack
  require "main_spec_helper"
  describe Version do
    it "changes version state" do
      version = create(:version)
      access_with_status(status: "allowed",version: version)
      version.edit_state_and_lic("not_forever", Date.yesterday.to_s)
      expect { version.save!}.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
    it 'retrieves #expiring_versions_without_ticket' do
      version = create(:version, end_lic: Date.today + 1.month, state: 'available')
      expect(Version.expiring_versions_without_ticket.to_a).to include version
    end
    it '#notify_about_expiring_versions' do
      Notificator.new.create_bot 'strong_password'
      version = create(:version, end_lic: Date.today + 1.month, state: 'available')
      Version.notify_about_expiring_versions
    end

  end
end
