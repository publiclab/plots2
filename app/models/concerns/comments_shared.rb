# Active Support concerns are a good way to use modules that can used across different models
# Refer to this link: http://stackoverflow.com/questions/14541823/how-to-use-concerns-in-rails-4
module CommentsShared
  extend ActiveSupport::Concern
  include ApplicationHelper

  # filtered version additionally appending http/https
  #   protocol to protocol-relative URLslike "/foo"
  def body_email(host = 'publiclab.org')
    if contain_trimmed_body?(body)
      comment_body = filtered_comment_body(body)
      return comment_body.gsub(/([\s|"|'|\[|\(])(\/\/)([\w]?\.?#{host})/, '\1https://\3')
    end
    body.gsub(/([\s|"|'|\[|\(])(\/\/)([\w]?\.?#{host})/, '\1https://\3')
  end

  def author
    return nil if uid.zero?

    User.find(uid)
  end

  def parent_commenter_uids
    commenter_ids = parent.comments.collect(&:uid).uniq
    commenter_ids.each do |commenter|
      commenter_ids.delete(commenter) if UserTag.exists?(commenter, 'notify-comment-indirect:false')
    end
  end

  def parent_liker_uids
    parent.likers.collect(&:uid)
  end

  def parent_reviser_uids
    (parent.revision.collect(&:uid).uniq - [parent.author.uid])
  end

  def uids_to_notify
    (parent_commenter_uids + parent_liker_uids + parent_reviser_uids).uniq
  end
end
