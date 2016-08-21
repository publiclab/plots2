class SettingsController < ApplicationController

  # Check the locale was passed and if it is a valid one, set the locale
  # with specific subdomain
  def change_locale
    lang = params[:locale].to_s.strip.to_sym
    lang = I18n.default_locale unless I18n.available_locales.include?(lang)

    if request.referer
      uri = URI(request.referer)
      if request.subdomains.first
        uri.host = lang.to_s + "." + uri.host.slice(3..-1)
      else
        uri.host = lang.to_s + "." + uri.host
      end
      url = uri.to_s
      redirect_to url + "?_=" + Time.now.to_i.to_s
    else
      redirect_to root_url(subdomain: lang.to_s)
    end

  end
end

