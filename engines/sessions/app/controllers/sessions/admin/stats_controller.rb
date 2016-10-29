module Sessions
  class Admin::StatsController < Admin::ApplicationController
    def index
      @session = Session.find(params[:session_id])
      @stats = @session.stats
    end

    def new
      @session = Session.find(params[:session_id])
      @stat = @session.stats.build
    end

    def create
      @session = Session.find(params[:session_id])
      @stat = @session.stats.build(stats_params)
      if @stat.save
        redirect_to admin_session_stats_path(@session)
      else
        render :new
      end
    end

    def download
      @stat = Stat.find(params[:stat_id])
      send_data @stat.to_csv, filename: "stats_#{@stat.id}.csv"
    end

    def detail
      @stat = Stat.find(params[:stat_id])
      @users = @stat.users_with_value(params[:value])
    end

    def edit
      @session = Session.find(params[:session_id])
      @stat = @session.stats.find(params[:id])
      render :new
    end

    def update
      @session = Session.find(params[:session_id])
      @stat = @session.stats.find(params[:id])
      if @stat.update_attributes(stats_params)
        redirect_to admin_session_stats_path(@session)
      else
        render :edit
      end
    end

    def destroy
      @stat = Stat.find(params[:id])
      @stat.destroy
      redirect_to [:admin, @stat.session]
    end

    private

    def stats_params
      params.require(:stat).permit( :group_by, :session_id,
                                    :survey_field_id, :organization_id,
                                    :weight)
    end
  end
end
