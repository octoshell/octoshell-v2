
class ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::AssetTagHelper

  # Accepts an int and displays a smiley based on >, <, or = 0
  # 
  

  def autocomplete_field(method, options = {}, html_options = {}, &block) 

    html_options[:class]= 'select2-ajax'
     data = { source: options.delete(:source), url: options.delete(:url) }
     html_options[:data] = data
     
     #display= object.send ( method.to_s.slice(0..-4)).
     #puts method.to_s.slice(0..-4)
     sel_opts=[]
    if options[:display]

      display_method=  options[:display]
      raise "error" if not   display_method.is_a?(String) 
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


class StaleFormBuilder<BootstrapForm::FormBuilder
   class_attribute :stale_field_helpers
   attr_accessor :stale_params
   self.stale_field_helpers = [  :text_field, :password_field,
                             :file_field, :text_area, :check_box,
                            :radio_button, :color_field, :search_field,
                            :telephone_field, :phone_field, :date_field,
                            :time_field, :datetime_field, :datetime_local_field,
                            :month_field, :week_field, :url_field, :email_field,
                            :number_field, :range_field]


    (stale_field_helpers - [ :check_box, :radio_button, :fields_for, :hidden_field, :file_field]).each do |selector|


        define_method(selector) do |name,options={}|
          if object.changed.include? name.to_s
            content_tag(:div,( super + render_check_box(name)))
           
          else
            super
          end

          
        end
        
      end
    def render_check_box(method)
      key=method.to_s + "_stale"
      box_name= "stale[#{key}]"

      checked=if stale_params
        stale_params[key] 
      else
        false
      end
      label(box_name,I18n.t('make available')) + check_box_tag(box_name,"1", checked,class: "stale_error" ) 
    end  


end  

module Pack

  
  module ApplicationHelper

    
    def pack_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.packages_list"),
                                        url: [:admin, :packages],
                                        regexp: /packages/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.accesses_list"),
                                        url: [:admin, :accesses],
                                        regexp: /accesses/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.options_list"),
                                        url: [:admin, :options_categories],
                                        regexp: /options_categories/}))
    
      menu.items
    end

   


    def reload_page
      render "helper_templates/reload_page"
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
