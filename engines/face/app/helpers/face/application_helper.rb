module Face
  module ApplicationHelper
    def display_wiki_link(name)
      page = Wiki.engines_links[name].first
      return '' unless page
      link_to page.name, wiki.page_path(page)
    end

    # def markdown_edit(&block)
    #   puts capture(&block)
    # end

    def markdown_area(f, method, options = {})
      # options.merge!({help: t(".markdown_help").html_safe})
      # puts options.inspect
      #puts f.text_field(method, options).inspect
      options[:"data-bar"] = '.bar1'
      options[:"data-preview"] = '.preview1'
      options[:class] = 'markdown-edit'

      render 'face/shared/linked2',{ text_area_field: f.text_area(method, options) }
    end

    def admin_user_short_link(user)
      return '' unless user
      profile = user.profile
      if profile.last_name
        name = initials profile
      else
        name = user.email
      end
      link_to name, main_app.admin_user_path(profile.user_id)
    end

    def admin?
      controller.class.name.split("::").include? "Admin"
    end

    def initials profile
       string = profile.last_name.dup
       string << " #{profile.first_name.first}." if profile.first_name.present?
       string << " #{profile.middle_name.first}." if profile.middle_name.present?
       string
    end

    def common_datepicker_options
    {
      include_blank: true, label_col: "col-sm-4", control_col: "col-sm-8",
      #:'data-date-start-date' => "#{DateTime.now.year}.01.01",
      :'data-date-end-date' => '1d', class: "datepicker"
    }
    end

    def display_all_tag
      content_tag(:div, class: "col-xs-12") do
        check_box_tag('q[display_all]', '1', display_all_applied?) +
        label_tag(t('without_pagination.display_all_records'))
      end
    end

    def page_entries_info(collection, options = {})
      return t 'without_pagination.displaying_all_records'  unless collection.arel.ast.cores.any? { |item| item.public_send(:top) }
      super
    end


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
        #field_content = form.collection_select options[:name], class: "form-control chosen ajax", data: data, role: options[:role]
        field_content = content_tag :select, options[:name], {
          name: options[:name],
          class: 'form-control select2-ajax',
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

    def safe_paginate(records)
      paginate records if records.respond_to? :current_page
    end

    def markdown(text)
      CommonMarker.render_html(text, :DEFAULT).html_safe
    end

    def wiki_markdown(text)
      logger.warn "render!"
      CommonMarker.render_html(text, [:DEFAULT, :UNSAFE],[:table,:autolink,:strikethrough]).html_safe
    end

  end
end
