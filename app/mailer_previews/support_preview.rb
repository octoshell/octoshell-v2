class SupportPreview
  def new_ticket
    ::Support::Mailer.new_ticket(Support::Ticket.first.id)
  end

  def new_ticket_reply
    ::Support::Mailer.new_ticket_reply(Support::Ticket.first.id, Support.user_class.first.id)
  end

  def reply_error
    ::Support::Mailer.reply_error(Support::Ticket.first.id, Support.user_class.first.id, 'Your errors')
  end
  def answered_tickets_notification
    ::Support::Mailer.answered_tickets_notification(User.first.id)
  end


end
