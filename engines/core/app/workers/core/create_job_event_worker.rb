module Core
  class CreateJobEventWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default, retry: 3

    def perform(job_id, rule_name)
      job = Jobstat::Job.find_by(id: job_id)
      return if job.nil?

      member = Core::Member.find_by_login(job.login)
      return if member.nil?

      job_notification = Core::JobNotification.find_by(name: rule_name)
      return if job_notification.nil?

      params = {
        job_id: job_id,
        user_id: member.user.id,
        project_id: member.project.id,
        job_notification_id: job_notification.id
      }

      controller = Core::JobNotificationEventsController.new
      controller.params = ActionController::Parameters.new(params)

      controller.create
    end
  end
end
