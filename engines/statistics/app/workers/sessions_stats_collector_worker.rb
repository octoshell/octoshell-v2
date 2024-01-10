class SessionStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    Statistics::SessionStat.calculate_stats
  end
end
