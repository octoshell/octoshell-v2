# announcement_recipients.find_each do |recipient|
#   Announcements::MailerWorker.perform_async(:announcement, recipient.id)
# end

class BatchSidekiq
  INTERVAL = 5.minutes
  BATCH_SIZE = 100
  class << self
    def call(worker, arg_array)
      arg_array.each_with_index do |a, i|
        worker.public_send(:perform_at, Time.now + i / BATCH_SIZE * INTERVAL, *a)
      end
    end
  end
end
