class OrganizationStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    Statistics::OrganizationStat.calculate_stats
  end
end
