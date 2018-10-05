user = User.find_by_email('support_bot@octoshell.ru')
user.update!(activation_state: 'active') if user.activation_state == 'pending'
topic_names = ['integration.support_theme_name', 'core.notificators.check.topic', 'pack.notificators.notify_about_expiring_versions.topic'].map do |name|
	I18n.t(name)
end
parent = Support::Topic.find_by_name_ru!('Уведомления')
Support::Topic.where(name_ru: topic_names).each do |topic|
	topic.update!(parent_topic: parent)
end
