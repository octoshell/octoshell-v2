class OrganizationStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :stats_collector

  def perform
    Statistics::OrganizationStat.calculate_stats
  end
end
