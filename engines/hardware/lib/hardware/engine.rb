module Hardware
  class Engine < ::Rails::Engine
    isolate_namespace Hardware
    # initializer "hardware.action_controller" do |app|
    #   ActiveSupport.on_load :action_controller do
    #     #helper Support::ApplicationHelper
    #     puts 'AAAA'.red
    #     # ActionController::Base.send(:include, Hardware::ApplicationHelper)
    #     ActionController::Base.send(:helper, Hardware::ApplicationHelper)
    #   end
    # end
  end
end
