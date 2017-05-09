# desc "Explaining what the task does"
# task :pack do
#   # Task goes here
# end
namespace :pack do
  task :expired => :environment do
    #time = Time.current
    #tar = "/var/www/octoshell2/shared/db_backups/#{time.strftime('%d%m%Y_%H%M')}.tar"
    #system "pg_dump -U octo -f #{tar} -F tar new_octoshell"
    #system "gzip #{tar}"
    ::Pack::PackWorker.perform_async(:expired)
    
  end
end


  

