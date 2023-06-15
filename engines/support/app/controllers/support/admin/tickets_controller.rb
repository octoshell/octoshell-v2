# coding: utf-8
module Support
  class Admin::TicketsController < Admin::ApplicationController
    before_action :setup_default_filter, only: :index

    skip_before_action :authorize_admins
    before_action only: :index do
      authorize!(:access, Topic)
    end

    before_action except: %i[index] do
      id = params[:id] || params[:ticket_id]

      next if id.blank? || can?(:access, Ticket.find(id).topic)

      raise CanCan::AccessDenied
    end

    def index
      @search = Ticket.search(params[:q])
      @tickets = @search.result(distinct: true)
                        .preload({ reporter: :profile}, { responsible: :profile },
                                  { field_values: {topics_field: {field: :field_options } }},
                                 :topic)
                        .where(topic: [Topic.accessible_by(current_ability, :access)])
      without_pagination(:tickets)
      # записываем отрисованные тикеты в куки, для перехода к следующему тикету после ответа
      cookies[:tickets_list] = @tickets.map(&:id).join(',')
    end

    def show
      @ticket = Ticket.eager_load(:tags, :subscribers, :replies).find(params[:id])
      @next_ticket = @ticket.find_next_ticket_from(cookies[:tickets_list])
    end

    def new
      @ticket = Ticket.new
      # init_field_values_form
    end

    def create
      @ticket = Ticket.new(ticket_params)
      not_authorized_access_to(@ticket)
      init_field_values_form
      @ticket.responsible = current_user

      # init_field_values_form
      # @field_values_form = Support::FieldValuesForm.new(@ticket, params[:ticket][:field_values])
      valid = @field_values_form.valid?
      if ticket_params.keys.count <= 1
        render :new
      elsif @ticket.valid? && valid
        @ticket.save!
        @ticket.subscribers << current_user
        redirect_to [:admin, @ticket]
      else
        render :new
      end
    end

    def close
      @ticket = Ticket.find(params[:ticket_id])
      if @ticket.close
        @ticket.save
        redirect_to [:admin, @ticket]
      else
        redirect_to [:admin, @ticket], alert: @ticket.errors.full_messages.to_sentence
      end
    end

    def reopen
      @ticket = Ticket.find(params[:ticket_id])
      if @ticket.reopen
        @ticket.save
        redirect_to [:admin, @ticket]
      else
        redirect_to [:admin, @ticket], alert: @ticket.errors.full_messages.to_sentence
      end
    end

    def edit
      @ticket = Ticket.find(params[:id])
      not_authorized_access_to(@ticket)
      init_field_values_form
    end

    def update
      @ticket = Ticket.find(params[:id])
      not_authorized_access_to(@ticket)
      respond_to do |format|
        format.html do
          @ticket.assign_attributes(ticket_params)
          init_field_values_form
          @previous_topic_id = params[:ticket].delete(:previous_topic_id)
          valid = @field_values_form.valid?
          if @ticket.valid? && valid && !ticket_require_edition?
            @ticket.save
            @ticket.destroy_stale_fields!
            redirect_to [:admin, @ticket]
          else
            render_edit_in_update
          end
        end

        format.json do
          @ticket.update(ticket_params)
          @ticket.save
          head :ok
        end
      end
    end

    def render_edit_in_update
      if ticket_require_edition?
        @new_fields = @ticket.new_fields(@previous_topic_id)
        @old_fields = @ticket.old_fields(@previous_topic_id)
        @ticket_require_edition = true
      end
      render :edit
    end

    def accept
      @ticket = Ticket.find(params[:ticket_id])
      @ticket.accept(current_user)
      @ticket.save
      redirect_to [:admin, @ticket]
    end

    def edit_responsible
      @ticket = Ticket.find(params[:id])
      @ticket.update!(ticket_params)
      @ticket.subscribers << @ticket.responsible unless @ticket.subscribers.include? @ticket.responsible
      redirect_to [:admin, @ticket]
    end

    private

    def ticket_require_edition?
      @previous_topic_id != ticket_params[:topic_id]
    end

    def setup_default_filter
      params[:q] ||= { state_in: ["pending", "answered_by_reporter"],
                      s: 'updated_at desc' }
    end

    def init_field_values_form
      second_arg = params[:ticket] && params[:ticket][:field_values]
      @field_values_form = Support::FieldValuesForm.new(@ticket, second_arg)
    end


    def ticket_params
      params.require(:ticket).permit(:message, :subject, :topic_id, :url,
                                     :project_id, :cluster_id, :surety_id,
                                     :reporter_id, :responsible_id, :attachment,
                                     tag_ids: [],
                                     subscriber_ids: [],
                                     field_values_attributes: [ :id,
                                                                :topics_field_id,
                                                                :ticket_id,
                                                                :value ] )
    end
  end
end
