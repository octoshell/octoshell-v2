user = User.find_by_email('support_bot@octoshell.ru')
user.update!(activation_state: 'active') if user.activation_state == 'pending'
