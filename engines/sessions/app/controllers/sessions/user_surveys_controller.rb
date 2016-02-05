module Sessions
  class UserSurveysController < ApplicationController
    layout "layouts/sessions/user"

    def index
      @search = current_user.surveys.search(params[:q] || default_index_params)
      @surveys = @search.result(distinct: true).page(params[:page])
    end

    def accept
      us = get_survey(params[:user_survey_id])
      if us.accept
        redirect_to us
      else
        redirect_to user_surveys_path, alert: us.errors.full_messages.to_sentence
      end
    end

    def show
      @survey = get_survey(params[:id])
    end

    def update
      @survey = get_survey(params[:id])
      if @survey.fill_values(survey_fields)
        redirect_to @survey
      else
        render :show
      end
    end

    def edit
      @survey = get_survey(params[:id])
      @survey.edit!
      redirect_to @survey
    end

    def submit
      @survey = get_survey(params[:user_survey_id])
      if @survey.fill_values_and_submit(survey_fields)
        redirect_to @survey
      else
        render :show
      end
    end

    private

    def get_survey(id)
      current_user.surveys.find(id)
    end

    def survey_fields
      params.require(:fields).permit!
    end

    def default_index_params
      params = {}
      if s = Session.current
        params[:session_id_eq] = s.id
      end
      params
    end
  end
end
