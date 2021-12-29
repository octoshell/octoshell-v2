module Perf::Admin
  class ApplicationController < Perf::ApplicationController
    before_action :check_abilities, :journal_user
    def check_abilities
      authorize! :manage, :packages
    end

  end
end
