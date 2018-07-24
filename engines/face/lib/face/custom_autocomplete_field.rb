module CustomAutocompleteField
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper
  extend ActiveSupport::Concern
  def autocomplete_field(method, options = {}, html_options = {}, &block)
    html_options[:class] = 'select2-ajax'
    data = { source: options.delete(:source), url: options.delete(:url) }
    html_options[:data] = data
    sel_opts = []
    value = object.send method
    sel_opts = options_for_select([[yield(value), value]]) if value.present?
    select(method, sel_opts, options, html_options, &block)
  end
end

ActionView::Helpers::FormBuilder.include CustomAutocompleteField
