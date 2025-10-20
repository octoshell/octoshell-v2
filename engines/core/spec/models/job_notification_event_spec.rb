    module Core
      require 'main_spec_helper'
      describe JobNotificationEvent do
        before(:each) do
          @project = create(:project)
          @user = @project.owner
          @global_default = create(:job_notification_global_default,
                                    notify_tg: false, notify_mail: false, kill_job: false)
          @notification = @global_default.job_notification
          @user_default = create(:job_notification_user_default,
                                 job_notification: @notification, user:   @user,
                                 notify_tg: true, notify_mail: true, kill_job: nil)
          @user = @user_default.user
          @project_setting = create(:job_notification_project_setting,
                                    job_notification: @notification,
                                    user: @user,
                                    project: @project,
                                    notify_tg: false, notify_mail: nil, kill_job: nil)
        end

        describe "::user_setting" do
          it "loads settings correctly" do
            expect(Core::JobNotificationEvent.user_setting(@user.id,
                                                           @project_setting.core_project_id,
                                                           @notification.id)).to eq(

              notify_tg: false,
              notify_mail: true,
              kill_job: false
            )
          end
        end

        describe "::create_from_job" do
          it "creates events only for one allowed notification" do
            job = create(:job, login: Core::Member.where(user_id: @user).last.login)
            notification2 = create(:job_notification)

            expect {
              JobNotificationEvent.create_from_job(job, [@notification.name, notification2.name, 'abra'])
            }.to change { JobNotificationEvent.count }.by(1)
            expect(JobNotificationEvent.last).to have_attributes(job_notification: @notification, user: @user)
          end
        end
        describe "::send_emails" do
          it "does not list early events" do
            job = create(:job, login: Core::Member.where(user_id: @user).last.login)
            Core::JobNotificationEvent.create!(perf_job: job,
                                               job_notification: @notification,
                                               core_project: @project,
                                               user: @user,
                                               created_at: Time.current - 6.minutes)
            expect{Core::JobNotificationEvent.send_emails}.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end

        describe "::to_be_sent_now" do
          it "does not list early events" do
            job = create(:job, login: Core::Member.where(user_id: @user).last.login)
            events = [Core::JobNotificationEvent.create!(perf_job: job,
                                               job_notification: @notification,
                                               core_project: @project,
                                               user: @user)]
            # notification2 = create(:job_notification)

            expect(JobNotificationEvent.to_be_sent_now.to_a).to eq([])
          end

          it "lists old events" do
            job = create(:job, login: Core::Member.where(user_id: @user).last.login)
            events = [Core::JobNotificationEvent.create!(perf_job: job,
                                               job_notification: @notification,
                                               core_project: @project,
                                               user: @user,
                                               created_at: Time.current - 6.minutes)]
            # notification2 = create(:job_notification)

            expect(JobNotificationEvent.to_be_sent_now.to_a).to eq(events)
          end

          it "lists events according to user notification settings " do
            job = create(:job, login: Core::Member.where(user_id: @user).last.login)
            events = [Core::JobNotificationEvent.create!(perf_job: job,
                                               job_notification: @notification,
                                               core_project: @project,
                                               user: @user,
                                               created_at: Time.current - 6.minutes)]

            UserNotificationSetting.create!(user: @user, notification_batch_interval: 10)
            expect(JobNotificationEvent.to_be_sent_now.to_a).to eq([])
          end

          it "shows settings correctly" do
            job = create(:job, login: Core::Member.where(user_id: @user).last.login)
            Core::JobNotificationEvent.create!(perf_job: job,
                                               job_notification: @notification,
                                               core_project: @project,
                                               user: @user,
                                               created_at: Time.current - 6.minutes)


            expect(JobNotificationEvent.to_be_sent_now.last).to(
            have_attributes(notify_tg: false,
                            notify_mail: true,
                            kill_job: false))
          end



        end


      end
    end
