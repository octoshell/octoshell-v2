module Hardware
  class Admin::ApplicationController < Hardware::ApplicationController
    layout "layouts/hardware/admin"
    before_filter :check_abilities
    def check_abilities
      authorize! :manage, :hardware
    end
  end
end
