module Support
  class Mailer < ActionMailer::Base
    def new_ticket(ticket_id)
      @ticket = Support::Ticket.find(ticket_id)
      support_emails = Support.user_class.support.pluck(:email)
      mail to: support_emails, subject: t(".subject")
    end

    def new_ticket_reply(ticket_id, user_id)
      @ticket = Support::Ticket.find(ticket_id)
      @user = Support.user_class.find(user_id)
      mail to: @user.email, subject: t(".subject", number: @ticket.id)
    end

    # TODO
    def answered_tickets_notification(user_id)
      @user = Support.user_class.find(user_id)
      @tickets = @user.tickets.with_state(:answered_by_support).where("updated_at < ?", 2.weeks.from.now)
      mail to: @user.email, subject: t(".subject")
    end
  end
end
