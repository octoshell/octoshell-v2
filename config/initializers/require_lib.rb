Dir["lib/**/*.rb"].reject { |f| f['receive_emails'] }.each {|file| require file[4..-1] }
require "contexts/user_abilities"
