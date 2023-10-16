class UserStatsCollectorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    Statistics::UserStat.calculate_stats
  end
end
