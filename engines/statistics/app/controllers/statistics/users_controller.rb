module Statistics
  class UsersController < Statistics::ApplicationController
    def index
    end

    def calculate_stats
      UserStatsCollectorWorker.perform_async
      head :ok
    end
  end
end
