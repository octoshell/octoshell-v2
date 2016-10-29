class SessionStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :stats_collector

  def perform
    Statistics::SessionStat.calculate_stats
  end
end
