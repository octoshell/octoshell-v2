module Core
  class Admin::MembersController < Admin::ApplicationController
    def index
      respond_to do |format|
        format.json do
          @members = Member.finder(params[:q])
          render json: { records: @members.page(params[:page])
                                          .per(params[:per]).map do |m|
                                    { id: m.id,
                                      text: m.login,
                                      project_id: m.project_id,
                                      user_id: m.user_id,
                                    }
                                  end, total: @members.count }
        end
      end
    end
  end
end
