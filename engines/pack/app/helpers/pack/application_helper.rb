module Pack
  
  module ControllerHelper
    
  end

  module ApplicationHelper
    def reload_page
      render "helper_templates/reload_page"
    end


    def check_attrs( class_name,attrs)
      attrs.each_value do |value|
        if !eval(class_name).find_by id: value[:id]
          value.delete(:id)
        end
      end
    end
    def link_to_add_options_fields  f 
      #new_object = f.object.class.reflect_on_association(association).klass.new
      #fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
       # render(association.to_s.singularize + "_fields", :f => builder)
      #end
      fields=render("vers_opt",f: f)
      link_to_function("name", "add_fields(this, \"#{escape_javascript(fields)}\")")
    end

    def link_to_function(name, function, html_options={})

        onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
        href = html_options[:href] || '#'

        content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
    end
  	
  end
end
