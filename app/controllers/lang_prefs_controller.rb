class LangPrefsController < ApplicationController

  def change
    if logged_in?
      lang_pref = LangPref.find_or_create_by(user_id: current_user.id)
      lang_pref.language = language_param
      lang_pref.save!
    end
    session[:locale] = language_param
    redirect_to :back
  end

  def language_param
    params.require(:language)
  end
end
