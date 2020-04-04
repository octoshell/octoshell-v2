module CustomAutocompleteField
  def autocomplete_field(method, options = {}, html_options = {}, &block)
    html_options[:class] ||=  ''
    html_options[:class] << ' select2-ajax'
    data = { source: options.delete(:source), url: options.delete(:url) }
    html_options[:data] = data
    sel_opts = [[]]
    begin
      value = object.send method
      #Rails.logger.warn "////// value=#{value} #{options} #{html_options}"
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
