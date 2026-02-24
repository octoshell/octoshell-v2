module Core
  class SshWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args = [])
      case template
      when 'calculate_resources'
        Core::ResourceControl.send(template)
      when 'sync_with_cluster'
        Core::QueueAccess.send(template, *args)
      else
        raise "Unknown job #{template} in SshWorker"
      end
    end
  end
end
