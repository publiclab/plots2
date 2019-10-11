# frozen_string_literal: true

module CommentHelper
  class CommentError < ArgumentError
  end

  def create_comment(node, user, body)
    @comment = node.add_comment(uid: user.uid, body: body)
    raise CommentError unless user && @comment.save

    @comment
  end
end
