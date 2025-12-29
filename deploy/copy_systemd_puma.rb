user = ENV["USER"]
target_path = ARGV[0]

systemd_path = "/home/#{user}/.config/systemd/user"
system("mkdir -p #{systemd_path}")

Dir.glob("#{Rails.root}/deploy/example_config/*.service") do |path|
  name = path.rpartition("/").last
  File.write("#{systemd_path}/#{name}", File.read(path).gsub('!deploy_to!', target_path))
end
File.write("#{Rails.root}/config/puma.rb", File.read("#{Rails.root}/deploy/example_config/puma.rb").gsub('!deploy_to!', target_path))
File.write("#{Rails.root}/deploy/nginx_octo", File.read("#{Rails.root}/deploy/example_config/nginx_octo").gsub('!deploy_to!', target_path))
