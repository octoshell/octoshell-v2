module Face
  module ApplicationHelper
    MARKED_JS = %Q(
      <script>
      var myMarked = window.marked;
      var marked_render = new myMarked.Renderer();
      function marked_video(title, text, style){
        var list = title.split(';');
        var result='<video controls';
        if(style!=''){
          result = result+style
        }
        result = result+'>'
        list.forEach(function(item) {
          var elems = item.split('=');
          result = result+'<source src="'+elems[1]+'" type="'+elems[0]+'">';
        });
        return result+text+'</video>';
      }
      marked_render.image = function (href, title, text) {
        var style='';
        var m = text.match(/\{.*\}/);
        var ms = String(m);
        if(ms!='' && ms!='null'){
          style = ' style="'+ms.slice(1,-1)+'"'
          text=text.replace(/\{.*\}/,'')
        }
        if(href=='video'){
          return marked_video(title, text, style);
        }
        var ret=''
        ret=ret+'<img src="'+href+'"'+style
        if(title!=null){
          ret=ret+' alt="'+title+'"';
        }
        var st = String(text);
        if(st!=''){
          ret=ret+' title="'+text+'"';
        }
        ret=ret+'/>';
        return ret;
      };
      </script>
    )
    def markdown_js
      text = if @marked_included.nil?
        @marked_included = true
        %Q(
        #{javascript_include_tag 'marked.min'}
        #{MARKED_JS}
        )
      else
        ''
      end
      js = if @md_js_included.nil?
        @md_js_included = true
        %Q(<script>
          $(function(){
            $('.marked-preview').each(function(e){
              var src = $('#'+$(this).attr('data-myid'));
              $(this).html(marked($(src).val(),{renderer: marked_render}));
            });
            $('.markdown-edit').each(function(){
              $(this).on('input', function(e){
                clearTimeout($(this).last_update);
                var src = $(this);
                $(this).last_update = setTimeout(function() {
                  var marked_text = marked(src.val(),{renderer: marked_render, gfm: true, smartLists: true});
                  $('.marked-preview[data-myid="'+src.attr('id')+'"]').html(marked_text);
                }, 500);
              })
            })
          });
          </script>
        )
      else
        ''
      end
      "#{text}#{js}".html_safe
    end

    def markdown_view
      text = if @marked_included.nil?
        @marked_included = true
        %Q(
        #{javascript_include_tag 'marked.min'}
        #{MARKED_JS}
        )
      else
        ''
      end
      js = if @js_view_included.nil?
        @js_view_included = true
        %Q(<script>
          $(function(){
            $('.markdown_view').each(function(e){
              var src = $(this).html();
              $(this).html(marked(src,{renderer: marked_render, gfm: true, smartLists: true}));
            })
          });
        </script>
        )
      else
        ''
      end
      "#{text}#{js}".html_safe
    end

    def display_wiki_link(name)
      page = Wikiplus.engines_links[name].first
      return '' unless page

      link_to page.name, wikiplus.page_path(page)
    end

    # def markdown_edit(&block)
    #   puts capture(&block)
    # end

    def markdown_area(f, method, options = {})
      # options.merge!({help: t(".markdown_help").html_safe})
      # puts options.inspect
      horizontal = options.delete(:horizontal)
      label = options.delete(:preview_label) || ''
      #options[:"data-bar"] = '.bar1'
      #options[:"data-preview"] = '.preview1'
      options[:"class"] = 'markdown-edit'

      if !horizontal
        render 'face/shared/linked2v', {
          #preview_id: "preview#{options[:id]}",
          text_area_field: f.text_area(method, options),
          preview_label: label,
          method: method
        }
      else
        render 'face/shared/linked2', {
          text_area_field: f.text_area(method, options),
          preview_label: label,
          method: method
        }
          # preview_id: "preview#{options[:id]}",
          # text_area_field: f.text_area(method, options),
          # preview: f.text_area(method, options.reject{|k,v|k==:id})}
      end
    end

    def admin_user_short_link(user)
      return '' unless user
      profile = user.profile
      if profile.last_name
        name = initials profile
      else
        name = user.email
      end
      link_to name, octo_url_for(:admin, user)
    end

    def admin?
      controller.class.name.split("::").include? "Admin"
    end

    def initials(profile)
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
      "<div class=\"markdown_view\">#{text}</div>\n#{markdown_view}".html_safe
      #CommonMarker.render_html(text, [:DEFAULT,:GITHUB_PRE_LANG, :UNSAFE, :TABLE_PREFER_STYLE_ATTRIBUTES],[:table,:autolink,:strikethrough]).html_safe
    end

    def wiki_markdown(text)
      "<div class=\"markdown_view\">#{text}</div>\n#{markdown_view}".html_safe
      #CommonMarker.render_html(text, [:DEFAULT, :UNSAFE, :GITHUB_PRE_LANG, :TABLE_PREFER_STYLE_ATTRIBUTES],[:table,:autolink,:strikethrough]).html_safe
      #"<div display=\"none\" id=\"preview_#{@preview_count}\">#{h(text)}</div><div class=\"marked-preview\" data-preview=#{preview_count}></div>".html_safe
    end

    def hard_markdown(text)
      CommonMarker.render_html(text, [:DEFAULT,:GITHUB_PRE_LANG, :UNSAFE, :TABLE_PREFER_STYLE_ATTRIBUTES],[:table,:autolink]).html_safe
    end
  end
end
