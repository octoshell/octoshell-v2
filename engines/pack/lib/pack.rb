require "pack/engine"
require "jquery-ui-rails"
require 'rails4-autocomplete'
require 'decorators'
require "pack/my_nested_attrs"
require "pack/date_custom"
require "aasm"
require "pack/support_integration"
require "ransack"
require "kaminari"


#require 'simple_form'

module Pack
	Date::DATE_FORMATS[:american] = "%m-%d-%Y" 
end
