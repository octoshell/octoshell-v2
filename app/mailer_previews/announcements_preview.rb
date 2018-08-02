class AnnouncementsPreview
  def announcement
    ::Announcements::Mailer.announcement(::AnnouncementRecipient.first.id)
  end
end
