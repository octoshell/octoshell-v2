# coding: utf-8
module Support
  class TicketsController < Support::ApplicationController
    before_action :require_login
    before_action :setup_default_filter, only: :index

    def index
      @search = current_user.tickets.ransack(params[:q])
      @tickets = @search.result(distinct: true)
                        .order("updated_at DESC, id DESC")
                        .page(params[:page])
    end

    def new
      @ticket = current_user.tickets.build
      @projects = current_user.projects
    end

    def continue
      @ticket = current_user.tickets.build(ticket_params)
      if @ticket.show_form?
        init_field_values_form
        # @field_values_form = Support::FieldValuesForm.new(@ticket)
      end
      @ticket.message = @ticket.template if @ticket.template.present?
      render :new
    end

    def create
      @ticket = current_user.tickets.build(ticket_params)
      @ticket.tags << @ticket.topic.tags
      init_field_values_form
      # @field_values_form = Support::FieldValuesForm.new(@ticket, params[:ticket][:field_values])
      valid = @field_values_form.valid?
      if @ticket.valid? && valid
        @ticket.save
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
      begin
        if @ticket.close
          @ticket.save
          redirect_to @ticket
          Core::BotLinksApiHelper.notify_about_ticket(@ticket, 'close')
        else
          redirect_to @ticket, alert: @ticket.errors.full_messages.join(', ')
        end
      rescue => e
        redirect_to @ticket, alert: [@ticket.errors.full_messages,e.message].flatten.join(', ')
      end
    end

    def resolve
      @ticket = find_ticket(params[:ticket_id])
      begin
        if @ticket.resolve
          @ticket.save
          redirect_to @ticket
          Core::BotLinksApiHelper.notify_about_ticket(@ticket, 'resolve')
        else
          @ticket.save
          redirect_to @ticket, alert: @ticket.errors.full_messages.join(', ')
        end
      rescue => e
        redirect_to @ticket, alert: [@ticket.errors.full_messages,e.message].flatten.join(', ')
      end
    end

    def reopen
      @ticket = find_ticket(params[:ticket_id])
      begin
        if @ticket.reopen
          @ticket.save
          redirect_to @ticket
          Core::BotLinksApiHelper.notify_about_ticket(@ticket, 'reopen')
        else
          redirect_to @ticket, alert: @ticket.errors.full_messages.join(', ')
        end
      rescue => e
        redirect_to @ticket, alert: [@ticket.errors.full_messages, e.message].flatten.join(', ')
      end
    end

    def edit
      @ticket = find_ticket(params[:id])
      init_field_values_form
    end

    # TODO: ajax
    def update
      @ticket = find_ticket(params[:id])
      @ticket.assign_attributes(ticket_params)
      init_field_values_form
      valid = @field_values_form.valid?
      if @ticket.valid? && valid
        @ticket.save
        redirect_to @ticket
        Core::BotLinksApiHelper.notify_about_ticket(@ticket, 'update')
      else
        render :edit
      end
    end

    private

    def ticket_params
      params.require(:ticket).permit(:message, :subject, :topic_id, :url,
                                     :project_id, :cluster_id,
                                     :attachment)
                                     # field_values_attributes: [ :id,
                                     #                            :topics_field_id,
                                     #                            :ticket_id,
                                     #                            :value ]
    end

    def find_ticket(id)
      current_user.tickets.find(id)
    end

    def setup_default_filter
      params[:q] ||= { state_not_in: ["closed"] }
      params[:meta_sort] ||= "id.asc"
    end

    def init_field_values_form
      second_arg = params[:ticket] && params[:ticket][:field_values]
      @field_values_form = Support::FieldValuesForm.new(@ticket, second_arg)
    end
  end
end
