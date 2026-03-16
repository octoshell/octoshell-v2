module Core
  class SshWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args = [])
      raise "Unknown job #{template} in SshWorker" unless %w[calculate_resources synchronize].include? template.to_s

      Core::ResourceControl.send(template, *args)
    end
  end
end
