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

  def body_email_html(host = 'publiclab.org')
    allowed_tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p iframe del hr img input code table thead tbody tr th td span dl dt dd div)

    # Sanitize the HTML (remove malicious attributes, unallowed tags...)
    # also see https://github.com/publiclab/plots2/blob/8daad1a70d022810b249a3d7882f6c4bd4fe3727/app/models/comment.rb#L513
    sanitized_body = ActionController::Base.helpers.sanitize(body_email(host), tags: allowed_tags)

    # render HTML from markdown
    RDiscount.new(sanitized_body)
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
