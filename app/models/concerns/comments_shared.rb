# Active Support concerns are a good way to use modules that can used across different models
# Refer to this link: http://stackoverflow.com/questions/14541823/how-to-use-concerns-in-rails-4
module CommentsShared
  extend ActiveSupport::Concern

  # filtered version additionally appending http/https
  #   protocol to protocol-relative URLslike "/foo"
  def body_email(host = 'publiclab.org')
    body.gsub(/([\s|"|'|\[|\(])(\/\/)([\w]?\.?#{host})/, '\1https://\3')
  end

  def author
    DrupalUsers.find_by(uid: uid)
  end

  def parent_commenter_uids
    parent.comments.collect(&:uid)
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
