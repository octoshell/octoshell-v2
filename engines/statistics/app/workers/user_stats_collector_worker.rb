class UserStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :stats_collector

  def perform
    Statistics::UserStat.calculate_stats
  end
end
