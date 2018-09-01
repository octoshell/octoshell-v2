module Comments
  class Admin::ApplicationController < Comments::ApplicationController
    layout 'layouts/comments/admin'
    before_filter :check_abilities
    def check_abilities
      authorize! :manage, :comments_engine
    end
  end
end
