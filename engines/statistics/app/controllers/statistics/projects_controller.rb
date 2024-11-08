module Statistics
  class ProjectsController < Statistics::ApplicationController
    def index
    end

    def calculate_stats
      ProjectStatsCollectorWorker.perform_async
      head :ok
    end
  end
end
