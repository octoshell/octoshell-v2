module Support
  class RepliesController < ApplicationController
    before_action :require_login

    def create
      p=reply_params

      @reply = Reply.new(p)
      @reply.author = current_user

      if current_user.ticket_ids.include?(@reply.ticket_id) && @reply.save
        redirect_to @reply.ticket
      else
        @ticket = @reply.ticket
        @replies = @ticket.replies
        redirect_to @reply.ticket, alert: @reply.errors.full_messages.to_sentence
      end
    end

    private

    def reply_params
      params.require(:reply).permit(:ticket_id, :message, :attachment)
    end
  end
end
