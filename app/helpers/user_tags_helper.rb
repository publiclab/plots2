module UserTagsHelper
  def fetch_tags(uid, type)
    tag_types = %w[skill gear role tool]
    tags = []
    if tag_types.include? type
      tags = UserTag.where(uid: uid).where('value LIKE ?', type + ':' + '%')
    end
    tags
  end
end
