
module Pack
  class PackWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args = 'default')
      if template == "expired"
        Pack::Version.expired_versions
        Pack::Version.notify_about_expiring_versions
        Pack::Access.expired_accesses
      else
        Pack::Mailer.send(template, *args).deliver_now!
      end
    end
  end
end
