# coding: utf-8
module Support
  class Admin::RepliesController < Admin::ApplicationController
    def create
      @reply = Reply.new(reply_params)
      @reply.author = current_user
      if @reply.save
        if params[:show_self].present?
          redirect_to [:admin, @reply.ticket]
        elsif params[:show_next].present?
          redirect_to next_ticket_path
        else
          redirect_to admin_tickets_path
        end
      else
        @ticket = @reply.ticket
        @replies = @ticket.replies
        render [:admin, @ticket]
      end
    end

    def next_ticket_path
      next_ticket = @reply.ticket.find_next_ticket_from(cookies[:tickets_list])
      if next_ticket
        [:admin, next_ticket]
      else
        # прошли по всему доступному списку ранее отрисованных тикетов, показываем новый
        admin_tickets_path
      end
    end

    private

    def reply_params
      params.require(:reply).permit(:ticket_id, :message, :attachment)
    end
  end
end
