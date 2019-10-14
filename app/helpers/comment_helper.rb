module CommentHelper
  class CommentError < ArgumentError
  end

  def create_comment(node, user, body)
    @comment = node.add_comment(uid: user.uid, body: body)
    successfully_saved = user && @comment.save
    raise CommentError unless successfully_saved

    @comment.notify(user)
    @comment
  end
end
