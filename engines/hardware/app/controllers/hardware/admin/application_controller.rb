module Hardware::Admin
  class ApplicationController < Hardware::ApplicationController
    layout "layouts/hardware/admin"
    before_action :check_abilities
    def check_abilities
      authorize! :manage, :hardware
    end

    def self.skip_before_actions(*actions, parameters)
      actions.each do |action|
        skip_before_action action, parameters
      end
    end
  end
end
