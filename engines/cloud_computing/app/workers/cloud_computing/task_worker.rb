
module CloudComputing
  class TaskWorker
    include Sidekiq::Worker
    sidekiq_options queue: :low

    def perform(method, *args)
      CloudComputing::OpennebulaTask.send(method, *args)
    end
  end
end
