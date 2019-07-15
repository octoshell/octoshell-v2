module Octoface
	def octo_config(&block)
		OctoConfig.new self, &block
	end
end
