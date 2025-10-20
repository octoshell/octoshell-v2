FactoryBot.define do
  factory :job_notification, class: "Core::JobNotification" do
    sequence(:name) { |n| "notification_#{n}" }
  end

  factory :job_notification_global_default, class: "Core::JobNotificationGlobalDefault" do
    job_notification { association :job_notification, global_default: instance }
  end

  factory :job_notification_project_setting, class: "Core::JobNotificationProjectSetting" do
    user
    project
    job_notification
  end

  factory :job_notification_user_default, class: "Core::JobNotificationUserDefault" do
    user
    job_notification
  end
end
