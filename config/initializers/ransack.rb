Ransack.configure do |c|
  #c.sanitize_custom_scope_booleans = false
end

# module Ransack::Naming
#   def model_name
#     self.class.model_name
#   end
# end

module SimpleForm::ActionViewExtensions::FormHelper
  alias_method :original_simple_form_for, :simple_form_for

  def simple_form_for(record, options = {}, &block)
    if record.instance_of?(Ransack::Search) && !options.key?(:as)
      options[:as] = :q
    end

    original_simple_form_for(record, options, &block)
  end
end