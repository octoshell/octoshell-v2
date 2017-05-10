require "pack/engine"
require "pack/date_custom"
require "pack/autocomplete_field"
require "decorators"
require "aasm"
require "slim"
require "sidekiq"
require "maymay"
require "ransack"
require "kaminari"
require "carrierwave"
require "mime-types"
require "jquery-ui-rails"

#require 'simple_form'

module Pack
	Date::DATE_FORMATS[:american] = "%m-%d-%Y" 
	mattr_accessor :support_access_topic_id
	
end
