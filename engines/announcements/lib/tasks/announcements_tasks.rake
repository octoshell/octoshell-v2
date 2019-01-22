namespace :announcements do
	task :remove_invalid_recipients => :environment do
		ActiveRecord::Base.transaction do
			AnnouncementRecipient.left_join(:announcement).where(announcements: { id: nil } ).distinct.destroy_all
		end
	end
end
