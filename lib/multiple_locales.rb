module MultipleLocales
  extend ActiveSupport::Concern
  def set_locale
    unless session[:locale]
      if logged_in?
        if session[:soul_id]
          session[:locale] = User.find(session[:soul_id]).language
        else
          session[:locale] = current_user.language if current_user.language
        end
      else
        session[:locale] = I18n.default_locale.to_s
      end
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end
  included do
    before_action :set_locale
  end
end
ActionController::Base.include MultipleLocales
