module Statistics
  class OrganizationsController < ApplicationController
    def index
    end

    def calculate_stats
      OrganizationStatsCollectorWorker.perform_async
      head :ok
    end
  end
end
