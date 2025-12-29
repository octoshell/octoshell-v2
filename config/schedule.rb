set :output, "#{Whenever.path}/log/cron.log"

every 1.day do
	rake "pack:expired"
  rake "authentication:delete_pending_users"
end

every 2.minutes do
 rake "fetch_inbox"
end


every 7.days do
	runner "Core::SshWorker.perform_async(:calculate_resources)"
end
