# encoding: utf-8

module Sessions
  class Admin::UserSurveysController < Admin::ApplicationController
    def show
      #authorize! :access, :user_surveys
      @us = UserSurvey.find(params[:id])
    end
  end
end
