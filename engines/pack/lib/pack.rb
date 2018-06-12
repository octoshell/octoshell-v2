require "pack/engine"
require "pack/date_custom"
# require "pack/autocomplete_field"
require "pack/pack_search"
# require "pack/access_validator"

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
require "active_record_union"

#require 'simple_form'

module Pack
  Date::DATE_FORMATS[:american] = "%m-%d-%Y"
end
