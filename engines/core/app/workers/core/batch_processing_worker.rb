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
      end

      unprocessed_events = Core::JobNotificationEvent.unprocessed
      return if unprocessed_events.empty?

      events_by_user = unprocessed_events.group_by(&:user_id)

      events_by_user.each do |user_id, user_events|
        process_user_events(user_id, user_events)
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

      log_entry = Core::JobNotificationEventLog.create!(
        user: user,
        events_count: events_count,
        summary_data: summary_data,
        details: generate_details(events, summary_data),
        start_period: start_period,
        end_period: end_period
      )

      events.each(&:mark_as_processed)

      notified_mail = false
      notified_tg = false
      if events_count > 0
        notifications = Core::JobNotification.where(id: events.map(&:core_job_notification_id).uniq)

        if notifications.any? { |notif| notif.user_settings(user)&.notify_mail }
          send_digest_email(user, log_entry)
          notified_mail = true
        end

        if notifications.any? { |notif| notif.user_settings(user)&.notify_tg }
          send_digest_telegram(user, log_entry)
          notified_tg = true
        end
      end

      Rails.logger.info "Processed #{events_count} events for user #{user.email} (ID: #{user.id}) for period #{start_period} to #{end_period}. Log ID: #{log_entry.id}. NotifiedMail: #{notified_mail}. NotifiedTg: #{notified_tg}"

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

      <<~DETAILS
        Обработано событий: #{summary[:total_count]}
        Диапазон времени: с #{summary[:time_range][:from]} по #{summary[:time_range][:to]}

        Уникальных уведомлений: #{summary[:unique_notifications]}
        Уникальных проектов: #{summary[:unique_projects]}
        Уникальных задач: #{summary[:unique_jobs]}

        Распределение по типам уведомлений:
        #{notification_details}

        Топ проектов:
        #{format_top_items(summary[:projects], 5)}

        Топ задач:
        #{format_top_items(summary[:jobs], 5)}
      DETAILS
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

    def send_digest_email(user, log_entry)
      Core::MailerWorker.perform_async(:job_notification, [user.id, log_entry.id])
    rescue => e
      Rails.logger.error "Error sending digest email to #{user.email}: #{e.message}"
    end

    def send_digest_telegram(user, log_entry)
      bot_link = user.bot_links.find_by_active(true)
      return unless bot_link

      params = {
        token: bot_link.token,
        email: user.email,
        events_count: log_entry.events_count,
        summary_data: log_entry.summary_data,
        details: log_entry.details,
        start_period: log_entry.start_period,
        end_period: log_entry.end_period
      }

      Core::BotLinksApiHelper.notify('/send_digest', params)

    rescue => e
      Rails.logger.error "Error sending telegram digest to #{user.email}: #{e.message}"
    end

  end
end
