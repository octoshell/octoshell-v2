class AuthenticationPreview
  def activation_needed
    ::Authentication::Mailer.activation_needed('a@a.ru', 'dddd')
  end

  def activation_success
    ::Authentication::Mailer.activation_success('a@@.ru')
  end

  def reset_password
    ::Authentication::Mailer.reset_password('a@@.ru', 'token')
  end
end
