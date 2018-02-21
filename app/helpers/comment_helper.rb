module CommentHelper
  class CommentError < ArgumentError
  end

  def create_comment(node, user, body)
    @comment = node.add_comment(uid: user.uid, body: body)
    if user && @comment.save
      @comment.notify user
      return @comment
    else
      raise CommentError.new()
    end
  end
end
