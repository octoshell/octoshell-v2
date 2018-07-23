module MultipleLocales
  extend ActiveSupport::Concern
  def set_locale
    if !session[:locale] && logged_in?
      session[:locale] = current_user.language if current_user.language
    elsif !session[:locale]
      session[:locale] = I18n.default_locale.to_s
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end
  included do
    before_action :set_locale
  end
end
ActionController::Base.include MultipleLocales
