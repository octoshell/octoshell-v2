module Statistics
  class OrganizationsController < Statistics::ApplicationController
    def index
    end

    def calculate_stats
      OrganizationStatsCollectorWorker.perform_async
      head :ok
    end
  end
end
