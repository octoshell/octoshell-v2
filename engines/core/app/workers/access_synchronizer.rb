class AccessSynchronizer
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 2

  RETRY_DELAY = 30

  def perform(access_id, scope = :full)
    synchronize(Core::Access.find(access_id), scope)
  rescue RedisMutex::LockError
    log_lock_timeout(access_id)
    self.class.perform_in(RETRY_DELAY, access_id, scope)
  end

  private

  def synchronize(access, scope)
    if scope.to_s == 'resource_controls'
      access.synchronize_resource_controls!
    else
      access.synchronize!
    end
  end

  def log_lock_timeout(access_id)
    Rails.logger.warn(
      "AccessSynchronizer lock timeout for access #{access_id}, retrying in #{RETRY_DELAY}s"
    )
  end
end
