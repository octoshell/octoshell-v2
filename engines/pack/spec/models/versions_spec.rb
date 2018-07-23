module Pack
	require "initial_create_helper"
	describe Version do
		it "changes version state" do
		  version = create(:version)
			access_with_status(status: "allowed",version: version)
		  version.edit_state_and_lic("not_forever", Date.yesterday.to_s)
		  expect { version.save!}.to change { ActionMailer::Base.deliveries.count }.by(1)
		end
	end
end
