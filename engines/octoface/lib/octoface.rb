require "octoface/railtie"
require "octoface/hook"
require "octoface/octo_config"
require "octoface/usage"

puts 'octoface'
module Octoface
  def octo_configure(role, &block)
    @octo_config ||= OctoConfig.new self, role, &block
  end

  def octo_config
    @octo_config
  end

  def self.action_and_subject_by_path(path)
    OctoConfig.action_and_subject_by_path(path)
  end

  def self.role_class?(role, class_name)
    OctoConfig.role_class?(role, class_name)
  end

  def self.mod_class_string(role, class_name)
    OctoConfig.mod_class_string(role, class_name)
  end
end

# puts __FILE__
puts __FILE__

arr = __FILE__.split('/')
arr[-1] = 'engines'
arr << '*'
# puts arr.join('/')
# puts File.join(Rails.root, 'engines', 'octoface', 'lib', 'engines')
# puts Dir.glob(File.join(Rails.root, 'engines', 'octoface', 'lib', 'engines', '*')).inspect.red

Dir.glob(arr.join('/')).each do |f|
  require f
end
Octoface::OctoConfig.finalize!
