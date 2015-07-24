# coding: utf-8
module Support
  class Admin::TicketsController < Admin::ApplicationController
    before_filter :setup_default_filter, only: :index

    def index
      @search = Ticket.search(params[:q])
      @tickets = @search.result(distinct: true)
                        .order("id DESC, updated_at DESC")
                        .page(params[:page])

      # записываем отрисованные тикеты в куки, для перехода к следующему тикету после ответа
      cookies[:tickets_list] = @tickets.map(&:id).join(',')
    end

    def show
      @ticket = Ticket.eager_load(:tags, :subscribers, :replies).find(params[:id])
      @next_ticket = @ticket.find_next_ticket_from(cookies[:tickets_list])
    end

    def new
      @ticket = Ticket.new
    end

    def create
      @ticket = Ticket.new(ticket_params)
      @ticket.responsible = current_user
      if @ticket.save
        @ticket.subscribers << current_user
        redirect_to [:admin, @ticket]
      else
        render :new
      end
    end

    def close
      @ticket = Ticket.find(params[:ticket_id])
      if @ticket.close
        redirect_to [:admin, @ticket]
      else
        redirect_to [:admin, @ticket], alert: @ticket.errors.full_messages.to_sentence
      end
    end

    def reopen
      @ticket = Ticket.find(params[:ticket_id])
      if @ticket.reopen
        redirect_to [:admin, @ticket]
      else
        redirect_to [:admin, @ticket], alert: @ticket.errors.full_messages.to_sentence
      end
    end

    def edit
      @ticket = Ticket.find(params[:id])
    end

    def update
      @ticket = Ticket.find(params[:id])

      respond_to do |format|
        format.html do
          if @ticket.update(ticket_params)
            redirect_to [:admin, @ticket]
          else
            render :edit, alert: @ticket.errors.full_messages.to_sentence
          end
        end

        format.json do
          @ticket.update(ticket_params)
          head :ok
        end
      end
    end

    def accept
      @ticket = Ticket.find(params[:ticket_id])
      @ticket.accept(current_user)
      redirect_to [:admin, @ticket]
    end

    private

    def setup_default_filter
      params[:q] ||= { state_in: ["pending", "answered_by_reporter"] }
    end

    def ticket_params
      params.require(:ticket).permit(:message, :subject, :topic_id, :url,
                                     :project_id, :cluster_id, :surety_id,
                                     :reporter_id, :responsible_id, :attachment,
                                     tag_ids: [],
                                     subscriber_ids: [],
                                     field_values_attributes: [ :id,
                                                                :field_id,
                                                                :ticket_id,
                                                                :value ] )
    end
  end
end
