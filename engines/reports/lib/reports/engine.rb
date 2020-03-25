module Reports
  class Engine < ::Rails::Engine
    isolate_namespace Reports
    paths["app/services"] 
  end
end
