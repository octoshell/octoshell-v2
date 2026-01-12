module Comments
  class ApplicationController < ::ApplicationController
    before_action :require_login
    layout 'layouts/comments/application'

    def ransackable_params
      attrs = %i[created_at_lt created_at_gt updated_at_gt updated_at_lt]
      params.require(:q).permit(attrs)
    end

    def check_abilities
      authorize! :manage, :comments_engine
    end
  end
end
