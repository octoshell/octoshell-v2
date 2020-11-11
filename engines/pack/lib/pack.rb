require "pack/engine"
require "pack/settings"
require "pack/pack_search"
require "decorators"
require "aasm"
require "slim"
require "sidekiq"
# require "maymay"
require "ransack"
require "kaminari"
require "carrierwave"
require "mime-types"
require "jquery-ui-rails"
require "active_record_union"
module Pack
	mattr_accessor :expire_after
end
