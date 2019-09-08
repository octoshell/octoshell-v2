class PackPreview
  def version_state_changed
    ::Pack::Mailer.version_state_changed(Pack::Access.first.id, Pack::Version.first.id)
  end

  def access_changed
    ::Pack::Mailer.access_changed(Pack::Access.first.id)
  end

  %w[allowed denied expired deleted end_lic denied_longer].map { |s| "access_changed_#{s}"}
                                    .each  do |method|
    define_method(method) do
      ::Pack::Mailer.public_send(method, Pack::Access.first.id)
    end
  end
end
