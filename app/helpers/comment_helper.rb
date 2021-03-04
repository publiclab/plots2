module CommentHelper
  class CommentError < ArgumentError
  end

  def create_comment(node, user, body)
    @comment = node.add_comment(uid: user.uid, body: body)
    if user && @comment.save
      @comment.notify user
      return @comment
    else
      raise CommentError
    end
  end

  # takes an activerecord query, returns a plain array
  # used in notes_controller.rb and comment_controller.rb
  def get_react_comments(comments_record, getting_replies = false)
    comments = []
    comments_record.each do |comment|
      next unless comment.reply_to.nil? || getting_replies
      comment_json = {}
      comment_json[:authorId] = comment.uid
      comment_json[:authorPicFilename] = comment.author.photo_file_name
      comment_json[:authorPicUrl] = comment.author.photo_path(:thumb)
      comment_json[:authorUsername] = comment.author.username
      comment_json[:commentId] = comment.cid
      comment_json[:commentName] = comment.name
      comment_json[:createdAt] = comment.created_at
      comment_json[:htmlCommentText] = raw insert_extras(filtered_comment_body(comment.render_body))
      comment_json[:rawCommentText] = comment.comment
      # nest the comment's replies in an array within the comment
      comment_json[:replies] = get_react_comments(comment.replied_comments, true)
      comment_json[:replyTo] = comment.reply_to
      time_created_string = distance_of_time_in_words(comment.created_at, Time.current, include_seconds: false, scope: 'datetime.time_ago_in_words' )
      comment_json[:timeCreatedString] = time_created_string
      comments << comment_json
    end
    comments
  end
end
