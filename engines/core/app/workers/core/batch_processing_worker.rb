require 'redis-mutex'

module Core
  class BatchProcessingWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3

    def perform(user_id = nil)
      if user_id
        lock_key = "perform_lock_user_#{user_id}"
        mutex = RedisMutex.new(lock_key, block: 10)

        mutex.with_lock do
          ActiveRecord::Base.transaction do
            user = User.find(user_id)
            user_settings = Core::UserNotificationSetting.for_user(user)
            batch_interval = user_settings.notification_batch_interval

            user_events = Core::JobNotificationEvent.mark_old_unprocessed_as_processed_for_user(user_id, batch_interval)

            logger.warn "user_events: #{user_events.size}"

            process_user_events(user_id, user_events)
          end
        end
      else
        unprocessed_events = Core::JobNotificationEvent.unprocessed
        return if unprocessed_events.empty?

        events_by_user = unprocessed_events.group_by(&:user_id)

        events_by_user.each do |u_id, user_events|
          process_user_events(u_id, user_events)
        end
      end
    end

    private

    def process_user_events(user_id, events)
      return if events.empty?

      user = User.find(user_id)

      start_period = events.map(&:created_at).min
      end_period = events.map(&:created_at).max

      process_period_events(user, events, start_period, end_period)
    end

    def process_period_events(user, events, start_period, end_period)
      return if events.empty?

      summary_data = prepare_summary(events)
      events_count = events.count
      details = generate_details(events, summary_data)

      events.each(&:mark_as_processed)

      notified_mail = false
      notified_tg = false
      if events_count > 0
        notifications = Core::JobNotification.where(id: events.map(&:core_job_notification_id).uniq)

        params = {
          events_count: events_count,
          summary_data: summary_data,
          details: details,
          start_period: start_period,
          end_period: end_period
        }

        if events.any? { |event| event.job_notification.user_settings(user, event.core_project)&.notify_mail }
          Core::MailJobNotificationWorker.perform_async(user.id, params)
          notified_mail = true
        end

        if events.any? { |event| event.job_notification.user_settings(user, event.core_project)&.notify_tg }
          Core::TelegramJobNotificationWorker.perform_async(user.id, params)
          notified_tg = true
        end

      end

      Rails.logger.info "Processed #{events_count} events for user #{user.email} (ID: #{user.id}) for period #{start_period} to #{end_period}. NotifiedMail: #{notified_mail}. NotifiedTg: #{notified_tg}"
    end

    def prepare_summary(events)
      notifications = events.group_by(&:core_job_notification_id)
                            .transform_keys { |id| "notification_#{id}" }
                            .transform_values(&:count)

      projects = events.group_by(&:core_project_id)
                      .transform_keys { |id| "project_#{id}" }
                      .transform_values(&:count)

      jobs = events.group_by(&:perf_job_id)
                  .transform_keys { |id| "job_#{id}" }
                  .transform_values(&:count)

      {
        total_count: events.count,
        unique_notifications: notifications.keys.count,
        unique_projects: projects.keys.count,
        unique_jobs: jobs.keys.count,
        notifications: notifications,
        projects: projects,
        jobs: jobs,
        time_range: {
          from: events.map(&:created_at).min,
          to: events.map(&:created_at).max
        }
      }
    end

    def generate_details(events, summary)
      notification_details = get_notification_details(events)

      [
        t("core.batch_processing_worker.details.total_processed", count: summary[:total_count]),
        t("core.batch_processing_worker.details.period", from: summary[:time_range][:from], to: summary[:time_range][:to]),
        "",
        t("core.batch_processing_worker.details.unique_notifications", count: summary[:unique_notifications]),
        t("core.batch_processing_worker.details.unique_projects", count: summary[:unique_projects]),
        t("core.batch_processing_worker.details.unique_jobs", count: summary[:unique_jobs]),
        "",
        t("core.batch_processing_worker.details.distribution_by_notification_types"),
        notification_details,
        "",
        t("core.batch_processing_worker.details.top_projects"),
        format_top_items(summary[:projects], 5),
        "",
        t("core.batch_processing_worker.details.top_jobs"),
        format_top_items(summary[:jobs], 5)
      ].join("\n")
    end

    def get_notification_details(events)
      notification_groups = events.group_by(&:core_job_notification_id)

      notification_groups.map do |notification_id, notification_events|
        notification = Core::JobNotification.find(notification_id)
        "  - #{notification.name}: #{notification_events.count} событий"
      end.join("\n")
    end

    def format_top_items(items_hash, limit = 5)
      items_hash.sort_by { |_, count| -count }
              .take(limit)
              .map { |id, count| "  - #{id}: #{count} событий" }
              .join("\n")
    end
  end
end
