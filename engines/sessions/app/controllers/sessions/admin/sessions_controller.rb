# encoding: utf-8

module Sessions
  class Admin::SessionsController < Admin::ApplicationController
    def index
      @sessions = Session.all.order("ended_at DESC NULLS FIRST")
    end

    def new
      @session = Session.new
    end

    def create
      @session = Session.new(session_params)
      if @session.save
        redirect_to admin_session_show_projects_path(@session), notice: t(".session_is_successfully_created")
      else
        flash.now[:alert] = @session.errors.full_messages.to_sentence
        render :new
      end
    end

    def show
      @session = get_session(params[:id])
    end

    def show_projects
      @session = Session.find(params[:session_id])
      params[:q] ||= { state_in: ["active"] }
      @search = Core::Project.search(params[:q])
      @projects = @search.result(distinct: true).preload(owner: [:profile]).preload(:organization).order(id: :desc)
      @projects_involved_in_session_ids = @session.involved_project_ids
    end

    def select_projects
      @session = Session.find(params[:session_id])
      @session.moderate_included_projects((params[:selected_project_ids] || []).map(&:to_i))

      redirect_to [:admin, @session]
    end

    def start
      @session = get_session(params[:session_id])
      if @session.start
        redirect_to [:admin, @session]
      else
        redirect_to [:admin, @session], alert: @session.errors.full_messages.to_sentence
      end
    end

    def stop
      @session = get_session(params[:session_id])
      if @session.stop
        redirect_to [:admin, @session]
      else
        redirect_to [:admin, @session], alert: @session.errors.full_messages.to_sentence
      end
    end

    def download
      @session = get_session(params[:session_id])
      # TODO sidekiq
      # Delayed::Job.enqueue SessionDataSender.new(@session.id, current_user.email)
      redirect_to [:admin, @session], notice: "Дождитесь письма со ссылкой на загрузку"
    end

    private

    def get_session(id)
      Session.find(id)
    end

    def session_params
      params.require(:session).permit(:description, :motivation, :receiving_to)
    end
  end
end
