namespace :db do
  task :backup => :environment do
    time = Time.current
    tar = "/var/www/octoshell2/shared/db_backups/#{time.strftime('%Y%m%d_%H%M')}.tar"
    system "pg_dump -f #{tar} -U octo -h 127.0.0.1 -F tar new_octoshell"
    system "bzip2 #{tar}"
  end
end
