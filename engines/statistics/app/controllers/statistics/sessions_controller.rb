module Statistics
  class SessionsController < ApplicationController
    def index
    end

    def calculate_stats
      SessionStatsCollectorWorker.perform_async
      head :ok
    end
  end
end
