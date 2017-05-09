


  # Accepts an int and displays a smiley based on >, <, or = 0
  # 
  

 
    



def admin? 
  controller.class.name.split("::").include? "Admin"
end





module Pack

  
  module ApplicationHelper

    def readable_attrs(record)
      record.attributes.reject{|key,value|  key.match(/_id$/) || ['id','lock_version','updated_at','created_at'].include?(key)  } 
    end

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
