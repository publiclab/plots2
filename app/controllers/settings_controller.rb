class SettingsController < ApplicationController
  def change_locale
    l = params[:locale].to_s.strip.to_sym
    l = I18n.default_locale unless I18n.available_locales.include?(l)
    cookies.permanent[:plots2_locale] = l
    redirect_to request.referer || root_url
  end
end