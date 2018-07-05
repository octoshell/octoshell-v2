module MultipleLocales
  extend ActiveSupport::Concern
  def set_locale
    if logged_in?
      @lang_pref = LangPref.find_by(user_id: current_user.id)
      session[:locale] = @lang_pref.language if @lang_pref
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end
  included do
    before_action :set_locale
  end
end
ActionController::Base.include MultipleLocales
