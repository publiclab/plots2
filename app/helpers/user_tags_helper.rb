module UserTagsHelper
  def fetch_tags uid, type
    tag_types = ['skill', 'gear', 'role', 'tool', 'language']
    tags = []
    if tag_types.include? type
      tags = UserTag.where(uid: uid).where("value LIKE ?", type + ":" + "%")
    end
    return tags
  end
  
  def locale_name_pairs
    locale_map = {}
    I18n.available_locales.each { |locale| locale_map[I18n.t('language', locale: locale)] = locale }
    return locale_map
  end
end
