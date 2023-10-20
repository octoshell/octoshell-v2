class ProjectStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    Statistics::ProjectStat.calculate_stats
  end
end
