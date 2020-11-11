module CustomAutocompleteField
  def autocomplete_field(method, options = {}, html_options = {}, &block)
    html_options[:class] ||=  ''
    html_options[:class] << ' select2-ajax'
    data = { source: options.delete(:source), url: options.delete(:url) }
    html_options[:data] = data
    sel_opts = [[]]
    begin
      value = options.key?(:initial_value) ? options[:initial_value] : object.send(method)
    rescue NoMethodError
      value = nil
    end
    if value.present? && block_given?
      sel_opts = Array(value).compact.map do |v|
        [yield(v), v]
      end
    end
    select(method, sel_opts, options, html_options)
  end
end

ActionView::Helpers::FormBuilder.include CustomAutocompleteField
