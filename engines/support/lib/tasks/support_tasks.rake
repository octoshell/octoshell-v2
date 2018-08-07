namespace :support do
	task :create_bot, [:pass] => :environment  do |_t, args|
		Support::Notificator.create_bot(args[:pass])
	end
end
