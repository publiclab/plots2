module UserTagsHelper
  def fetch_tags uid, type
    tag_types = ['skill', 'gear', 'role', 'tool']
    tags = []
    if tag_types.include? type
      tags = UserTag.where(uid: uid).where("value LIKE ?", type + ":" + "%")
    end
    return tags
  end
end
