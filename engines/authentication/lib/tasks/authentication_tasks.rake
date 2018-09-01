# desc "Explaining what the task does"
# task :authentication do
#   # Task goes here
# end
namespace :authentication do
  task :delete_pending_users => :environment do
    User.delete_pending_users
  end
end
