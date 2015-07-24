module Face
  module ApplicationHelper
    def bootstrap_class_for(flash_type)
      case flash_type
      when "success"
        "alert-success" # Green
      when "error"
        "alert-danger" # Red
      when "alert"
        "alert-warning" # Yellow
      when "notice"
        "alert-info" # Blue
      else
        flash_type
      end
    end

    def autocomplete(form, options = {})
      content_tag(:div, class: "form-group") do
        layout = options.delete(:layout)
        hide_label = options.delete(:hide_label)
        data = { source: options[:source], url: options[:url] }
        label_content =  content_tag :label, (options[:label].presence || "")
        field_content = form.hidden_field options[:name], class: "form-control chosen ajax", data: data, role: options[:role]
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
          if hide_label
            field_div.html_safe
          else
            (label_div + field_div).html_safe
          end
        end
      end
    end

    def safe_paginate(records)
      paginate records if records.respond_to? :current_page
    end

    def markdown(text)
      Kramdown::Document.new(text, filter_html: true).to_html.html_safe
    end
  end
end
