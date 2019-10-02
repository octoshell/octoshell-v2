module Octoface
  def octo_configure(role, &block)
    @octo_config = OctoConfig.new self, role, &block
  end

  def octo_config
    @octo_config
  end

  def self.action_and_subject_by_path(path)
    OctoConfig.action_and_subject_by_path(path)
  end
end
