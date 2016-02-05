# coding: utf-8
module Support
  class TicketsController < ApplicationController
    before_filter :require_login
    before_filter :setup_default_filter, only: :index

    def index
      @search = current_user.tickets.search(params[:q])
      @tickets = @search.result(distinct: true)
                        .order("id DESC, updated_at DESC")
                        .page(params[:page])
    end

    def new
      @ticket = current_user.tickets.build
      @projects = current_user.projects
    end

    def continue
      @ticket = current_user.tickets.build(ticket_params)
      if @ticket.show_form?
        @ticket.topic.fields.each do |topic_field|
          @ticket.field_values.build do |value|
            value.field = topic_field
          end
        end
      end
      render :new
    end

    def create
      @ticket = current_user.tickets.build(ticket_params)
      @ticket.tags << @ticket.topic.tags
      if @ticket.save
        redirect_to @ticket
      else
        render :new
      end
    end

    def show
      @ticket = find_ticket(params[:id])
    end

    def close
      @ticket = find_ticket(params[:ticket_id])
      if @ticket.close
        redirect_to @ticket
      else
        redirect_to @ticket, alert: @ticket.errors.full_messages.join(', ')
      end
    end

    def resolve
      @ticket = find_ticket(params[:ticket_id])
      if @ticket.resolve
        redirect_to @ticket
      else
        redirect_to @ticket, alert: @ticket.errors.full_messages.join(', ')
      end
    end

    def edit
      @ticket = find_ticket(params[:id])
    end

    # TODO: ajax
    def update
      @ticket = find_ticket(params[:id])
      if @ticket.update(ticket_params)
        redirect_to @ticket
      else
        render :edit
      end
    end

    private

    def ticket_params
      params.require(:ticket).permit(:message, :subject, :topic_id, :url,
                                     :project_id, :cluster_id,
                                     :attachment,
                                     field_values_attributes: [ :id,
                                                                :field_id,
                                                                :ticket_id,
                                                                :value ] )
    end

    def find_ticket(id)
      current_user.tickets.find(id)
    end

    def setup_default_filter
      params[:q] ||= { state_not_in: ["closed"] }
      params[:meta_sort] ||= "id.asc"
    end
  end
end
