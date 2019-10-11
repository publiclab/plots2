# frozen_string_literal: true

module UserTagsHelper
  def fetch_tags(uid, type)
    tag_types = %w[skill gear role tool]
    tags = []
    tags = UserTag.where(uid: uid).where('value LIKE ?', type + ':' + '%') if tag_types.include? type
    tags
  end
end
