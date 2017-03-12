require "pack/engine"
require "jquery-ui-rails"
require 'rails4-autocomplete'
require 'kaminari'
require 'decorators'
require "pack/my_nested_attrs"
require "aasm"


#require 'simple_form'

module Pack
	Date::DATE_FORMATS[:default] = "%m-%d-%Y" 
end
