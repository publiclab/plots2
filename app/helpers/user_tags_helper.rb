module UserTagsHelper
  def fetch_tags type
    tag_types = ['skill', 'gear', 'role', 'tool']
    tags = []
    if tag_types.include? type
      tags = UserTag.where("value LIKE ?", type + ":" + "%")
    end
    return tags
  end
end
