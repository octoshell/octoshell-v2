module Pack
  module ApplicationHelper
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
