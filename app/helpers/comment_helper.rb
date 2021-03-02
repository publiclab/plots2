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
    comments_record.each_with_index do |comment, index|
      if comment.reply_to.nil? || getting_replies
        commentJSON = {}
        commentJSON[:authorId] = comment.uid
        commentJSON[:authorPicFilename] = comment.author.photo_file_name
        commentJSON[:authorPicUrl] = comment.author.photo_path(:thumb)
        commentJSON[:authorUsername] = comment.author.username
        commentJSON[:commentId] = comment.cid
        commentJSON[:commentName] = comment.name
        commentJSON[:createdAt] = comment.created_at
        commentJSON[:htmlCommentText] = raw insert_extras(filtered_comment_body(comment.render_body))
        commentJSON[:rawCommentText] = comment.comment
        # nest the comment's replies in an array within the comment
        commentJSON[:replies] = get_react_comments(comment.replied_comments, true)
        commentJSON[:replyTo] = comment.reply_to
        time_created_string = distance_of_time_in_words(comment.created_at, Time.current, { include_seconds: false, scope: 'datetime.time_ago_in_words' })
        commentJSON[:timeCreatedString] = time_created_string
        comments << commentJSON
      end
    end
    comments
  end
end
