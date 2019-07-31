require 'test_helper'
require "minitest/reporters"
require 'common_helper'

Minitest::Reporters.use!
#require "bundler/gem_tasks"
#require "rake/testtask"
$global_test = true
Dir[Rails.root.join("engines/*/test/test.rb")].each { |f| require f }
#require "/old/home/serg/Work/Octoshell/octoshell-v2-github/engines/jobstat/test/jobstat_test.rb"
