require "maymay"
require "wikiplus/engine"
require "#{Wikiplus::Engine.root}/../../lib/model_translation/active_record_validation"

module Wikiplus
	mattr_accessor :engines_links
end
