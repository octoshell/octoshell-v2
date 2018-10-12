module Comments
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout 'layouts/comments/application'

    def ransackable_params
      attrs = %i[created_at_lt created_at_gt updated_at_gt updated_at_lt]
      params.require(:q).permit(attrs)
    end
  end
end
