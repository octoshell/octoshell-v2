module Pack
  module ApplicationHelper
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
  	def my_autocomplete( options = {})
      content_tag(:div, class: "form-group") do
        layout = options.delete(:layout)
        hide_label = options.delete(:hide_label)
        data = { source: options[:source], url: options[:url] }
        label_content =  content_tag :label, (options[:label].presence || "")
        #field_content = form.collection_select options[:name], class: "form-control chosen ajax", data: data, role: options[:role]
        field_content = content_tag :select, options[:name], {
          name: options[:name],
          
          id: 'version_id',
          data: data,
          role: options[:role]
        }
        #warn "======c #{field_content} // #{field_content.html_safe}"

        case layout
        when :regular
          label_div = content_tag(:div, class: "control-label") { label_content }
          if hide_label
            field_content.html_safe
          else
            (label_div + field_content).html_safe
          end
        else
          label_div = content_tag(:div, class: "control-label col-sm-2") { label_content }
          field_div = content_tag(:div, class: "col-sm-10") { field_content }
          #warn "====== #{field_div}"
          if hide_label
            field_div.html_safe
          else
            (label_div + field_div).html_safe
          end
        end
      end
    end
  end
end
