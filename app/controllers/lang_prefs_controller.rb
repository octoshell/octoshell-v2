class LangPrefsController < ApplicationController

  def change
    if logged_in?
      current_user.language = language_param
      current_user.save!
    end
    session[:locale] = language_param
    redirect_to :back
  end

  def language_param
    params.require(:language)
  end
end
