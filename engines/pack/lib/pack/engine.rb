module Pack
  class Engine < ::Rails::Engine
    isolate_namespace Pack
    config.to_prepare do
      Decorators.register! Engine.root
    end
    #config.before_initialize do                                                      
     # config.i18n.load_path += Dir[Rails.root.join('engines', 'pack','config','locales', '*.{rb,yml}')]
    #end
  end


 
	
	#Date::DATE_FORMATS[:default] = "%m-%d-%Y" 



end
