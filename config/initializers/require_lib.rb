Dir["lib/**/*.rb"].each {|file| require file[4..-1] }
require "contexts/user_abilities"
