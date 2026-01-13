# announcement_recipients.find_each do |recipient|
#   Announcements::MailerWorker.perform_async(:announcement, recipient.id)
# end

class BatchSidekiq
  INTERVAL = 5.minutes
  BATCH_SIZE = 300
  class << self
    def call(worker, arg_array)
      arg_array.each_with_index do |a, i|
        worker.public_send(:perform_at, Time.now + i / BATCH_SIZE * INTERVAL, *a)
      end
    end

    def raise_error_if_limit_reached(count)
      raise "limit is too small for #{count} emails" if count > BATCH_SIZE

      RedisMutex.with_lock(:email_lock, block: 5) do
        cur_limit = redis.get :email_limit
        unless cur_limit
          redis.set(:email_limit, BATCH_SIZE, ex: INTERVAL.to_i)
          cur_limit = BATCH_SIZE
        end
        cur_limit = cur_limit.to_i
        raise "Email limit is reached when sending #{count} emails" if count > cur_limit

        redis.set(:email_limit, cur_limit - count, keepttl: true)
      end
    end

    private

    def redis
      RedisClassy.redis
    end
  end
end
