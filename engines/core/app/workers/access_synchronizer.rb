class AccessSynchronizer
  include Sidekiq::Worker
  sidekiq_options queue: :synchronizer, retry: 2

  def perform(access_id)
    access = Core::Access.find(access_id)
    access.synchronize!
  end
end
