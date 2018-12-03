module CommentHelper
  class CommentError < ArgumentError
  end

  def create_comment(node, user, body)
    status = 1
    if user.first_time_poster && user.first_time_commenter
      status = 4
    end
    @comment = node.add_comment(uid: user.uid, body: body, status: status)
    if user && @comment.save
      @comment.notify user
      return @comment
    else
      raise CommentError
    end
  end
end
