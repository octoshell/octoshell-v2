
module CloudComputing
  class TaskWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :low

    def perform(method, *args)
      CloudComputing::OpennebulaTask.send(method, *args)
    end
  end
end
