module Pack
  require 'main_spec_helper'
  describe Package do
    it 'sends emails when allowed access is created' do
      package = create(:package, accesses_to_package: true)
      create(:version, package: package)
      user = create(:user)
      # access_with_status(to: package, status: 'allowed')
      # puts ActionMailer::Base.deliveries.last(3).map(&:to).inspect.red
      expect{access_with_status(to: package, status: 'allowed',
                                created_by: user, who: user)}.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "desends emails when requested access is created" do
      package = create(:package, accesses_to_package: true)
      create(:version, package: package)
      user = create(:user)
      expect{access_with_status(to: package, status: 'requested',
                                created_by: user, who: user)}.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

  end
end
