

module CustomAutocompleteField
   include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::AssetTagHelper
  extend ActiveSupport::Concern
  def autocomplete_field(method, options = {}, html_options = {}, &block) 

    html_options[:class]= 'select2-ajax'
     data = { source: options.delete(:source), url: options.delete(:url) }
     html_options[:data] = data
     
     
     sel_opts=[]
    if options[:display]

      display_method=  options[:display]
      raise "display option must be a string" if not   display_method.is_a?(String) 
      begin 
        result= object.instance_eval(display_method) 
      rescue NoMethodError 
          nil
      end
      sel_opts=options_for_select([[result,object.send(method)]] )
    end
     
     select(method,  sel_opts, options, html_options, &block)  
    
    
  end

end

 ActionView::Helpers::FormBuilder.include CustomAutocompleteField