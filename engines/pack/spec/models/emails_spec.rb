module Pack
  require 'main_spec_helper'
  describe Package do
    it "deletes package,package's versions,versions' accesses" do
      package = create(:package)
      create(:version, package: package)
      expect{access_with_status(to: package, status: 'allowed')}.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
