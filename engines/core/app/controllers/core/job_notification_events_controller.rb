# module Core
#     class JobNotificationEventsController < ApplicationController
#       # POST /core/event_occurred
#       def create
#         job_id = params[:job_id]
#         user_id = params[:user_id]
#         project_id = params[:project_id]
#         job_notification_id = params[:job_notification_id]
#
#         unless job_id.present? && user_id.present? && project_id.present? && job_notification_id.present?
#           return render json: { error: 'Missing required parameters' }, status: :bad_request
#         end
#
#         notification = JobNotification.find_by(id: job_notification_id)
#         user = User.find_by(id: user_id)
#         project = Project.find_by(id: project_id)
#
#         logger.warn "#{notification}; #{user}; #{project_id}"
#
#         unless notification && user && project
#           return render json: { error: 'Invalid notification, user or project ID' }, status: :not_found
#         end
#
#         notification_settings = JobNotificationSettingsHelper.get_notification_settings(notification, user, project)
#
#         if notification_settings[:kill_job]
#           logger.warn "Cancelling job #{job_id}."
#           JobCanceller.cancel_job_by_job_id(job_id)
#         end
#
#         if notification_settings[:notify_mail] || notification_settings[:notify_tg]
#           event = JobNotificationEvent.create!(
#             core_job_notification_id: notification.id,
#             user: user,
#             core_project_id: project.id,
#             perf_job_id: job_id,
#             data: params[:data] || {}
#           )
#
#           schedule_batch_processing(user.id)
#
#           render json: { status: 'accepted', notify_mail: true, event_id: event.id }, status: :accepted
#         else
#           render json: { status: 'ignored', notify_mail: false }, status: :ok
#         end
#       end
#
#       # GET /core/events
#       def index
#         @events = JobNotificationEvent.includes(:job_notification, :user, :core_project)
#                                      .order(created_at: :desc)
#                                      .page(params[:page]).per(50)
#
#         respond_to do |format|
#           format.html
#           format.json { render json: @events }
#         end
#       end
#
#       # GET /core/events/:id
#       def show
#         @event = JobNotificationEvent.find(params[:id])
#
#         respond_to do |format|
#           format.html
#           format.json { render json: @event }
#         end
#       end
#
#       # POST /core/events/process_batch
#       def process_batch
#         BatchProcessingWorker.perform_async
#
#         redirect_to job_notification_events_path, notice: t('.process_batch.notice')
#       end
#
#
#       private
#
#       def schedule_batch_processing(user_id)
#         user = User.find(user_id)
#         user_settings = Core::UserNotificationSetting.for_user(user)
#         batch_interval = user_settings.notification_batch_interval
#
#         BatchProcessingWorker.perform_in(batch_interval.minutes + 1.minutes, user_id)
#       end
#     end
#   end
