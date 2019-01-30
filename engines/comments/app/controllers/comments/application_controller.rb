module Comments
  class ApplicationController < ::ApplicationController
    include AuthMayMay
    layout 'layouts/comments/application'

    def ransackable_params
      attrs = %i[created_at_lt created_at_gt updated_at_gt updated_at_lt]
      params.require(:q).permit(attrs)
    end
    
#    before_filter :journal_user
#
#    def journal_user
#      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
#    end
  end
end
