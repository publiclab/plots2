module ApplicationHelper

  # returns true if user is logged in and has any of the roles given, as ['admin','moderator']
  def logged_in_as(roles)
    if current_user
      has_valid_role = false
      roles.each do |role|
        has_valid_role = true if current_user.role == role
      end
      return has_valid_role
    else
      return false
    end
  end

  def feature(title)
    features = DrupalNode.where(type: 'feature', title: title)
    if features.length > 0
      return features.last.body.html_safe
    else
      ""
    end
  end
  
  def locale_name_pairs
    locale_map = {}
    I18n.available_locales.each { |locale| locale_map[I18n.t('language', locale: locale)] = locale }
    return locale_map
  end

end
