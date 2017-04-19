class SettingsController < ApplicationController
  # Check the locale was passed and if it is a valid one, set the locale
  def change_locale
    lang = params[:locale].to_s.strip.to_sym
    lang = I18n.default_locale unless I18n.available_locales.include?(lang)
    cookies.permanent[:plots2_locale] = lang
    I18n.locale = lang
    if request.referer
      redirect_to request.referer + '?_=' + Time.now.to_i.to_s
    else
      redirect_to root_url
    end
  end
end
