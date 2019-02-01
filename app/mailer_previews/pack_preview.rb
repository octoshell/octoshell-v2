class PackPreview
  def email_vers_state_changed
    ::Pack::Mailer.email_vers_state_changed(Pack::Access.first.id)
  end

  def access_changed
    ::Pack::Mailer.access_changed(Pack::Access.first.id)
  end
end
