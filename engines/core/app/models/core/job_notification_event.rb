module Core
  class JobNotificationEvent < ApplicationRecord
    self.table_name = 'core_job_notification_events'

    belongs_to :job_notification,
               class_name: 'Core::JobNotification',
               foreign_key: 'core_job_notification_id'

    belongs_to :user

    belongs_to :core_project,
               class_name: 'Core::Project',
               foreign_key: 'core_project_id'

    belongs_to :perf_job, class_name: 'Perf::Job', optional: true

    validates :core_job_notification_id, :user_id, :core_project_id, :perf_job_id, presence: true


    # scope :unprocessed, -> { where(processed: false) }
    # scope :unprocessed_status, -> { where(status: "unprocessed") }
    scope :older_than, ->(minutes) { where("created_at <= ?", minutes.minutes.ago) }


    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :status) do
      state :pending, :initial => true # свежесозданный проект
      state :processed
      event :process do
        transitions from: :pending, to: :processed
        after do
          update!(processed_at: Time.current)
        end
      end
    end
    # def mark_as_processed
    #   update(processed: true, processed_at: Time.current, status: "processed")
    # end
    #
    # def self.mark_old_unprocessed_as_processed_for_user(user_id, minutes)
    #   transaction do
    #     events = unprocessed.older_than(minutes).where(user_id: user_id).lock
    #
    #     event_ids = events.pluck(:id)
    #
    #     events.update_all(processed: true, processed_at: Time.current, status: "processed")
    #
    #     where(id: event_ids)
    #   end
    # end

    def self.to_be_sent_now
      join_conditions = {
        core_job_notification_project_settings: %w[user_id core_project_id core_job_notification_id],
        core_job_notification_user_defaults: %w[user_id core_job_notification_id],
        core_job_notification_global_defaults: %w[core_job_notification_id]
      }
      relation = pending.joins("LEFT JOIN core_user_notification_settings AS n_s ON n_s.user_id = core_job_notification_events.user_id")
                        .where("core_job_notification_events.created_at < NOW() - (COALESCE(n_s.notification_batch_interval, 5)  || ' minutes')::INTERVAL")
      join_conditions.each do |table, attributes|
        cond = attributes.map { |a| "#{table_name}.#{a} = #{table}.#{a}"}
                         .join(' AND ')
        relation = relation.joins("LEFT JOIN #{table} ON  #{cond} ")
      end
      select_string = JobNotification::ACTIONS.map do |action|
        j_c = join_conditions.keys.map{ |table| "#{table}.#{action}" }.join(',')
        "COALESCE(#{j_c}) AS #{action}"
      end.join(', ')
      relation.select("core_job_notification_events.*, #{select_string}")
    end

    def self.send_emails
      to_be_sent_now.select{ |r| r['notify_mail'] }
                    .group_by(&:user_id).each do |user_id, events|
        events.each(&:process!)
        ::Core::MailerWorker.perform_async(:job_notification, [user_id, events.map(&:id)])
      end
    end


    def self.create_from_job(job, rules)
      member = ::Core::Member.find_by_login(job.login)
      return if member.nil?

      rules.each do |rule|
        job_notification = ::Core::JobNotification.find_by(name: rule)
        next if job_notification.nil?

        u_s = user_setting(member.user_id, member.project_id, job_notification.id)

        if u_s[:kill_job]

        end

        if u_s[:notify_tg] || u_s[:notify_mail]
          where(
            job_notification: job_notification,
            user_id: member.user_id,
            core_project_id: member.project_id,
            perf_job: job
          ).first_or_create!
        end


      end
    end

    def self.user_setting(user_id, project_id, notification_id)
      [
        ::Core::JobNotificationProjectSetting.find_by(user_id: user_id,
                                                    core_project_id: project_id,
                                                    core_job_notification_id: notification_id),
        ::Core::JobNotificationUserDefault.find_by(user_id: user_id,
                                                 core_job_notification_id: notification_id),
        ::Core::JobNotificationGlobalDefault.find_by(core_job_notification_id: notification_id)
      ].each_with_object({}) do |cur, res|
        JobNotification::ACTIONS.each do |action|
          (res[action] = cur.try(action)) if res[action].nil?
        end
      end
    end
  end
end
