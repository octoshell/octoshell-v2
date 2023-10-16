module Perf
  class Worker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :low

    def perform(method, args)
      return unless method.to_s == 'count_project_stats'

      count_project_stats(*args)
    end

    def count_project_stats(session_id)
      rows = Perf::Comparator.new(session_id).brief_project_stat.execute
      hash = Perf::ComparatorFormatter.call(rows)
      Rails.cache.write("project_stat_#{session_id}",
                        hash, expires_in: 4.months)
    end
  end
end
