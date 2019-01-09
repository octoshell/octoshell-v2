class ProjectStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :stats_collector

  def perform
    Statistics::ProjectStat.calculate_stats
  end
end
