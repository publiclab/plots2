import React from "react";
import PropTypes from "prop-types";

import Comment from "./Comment";

const CommentReplies = ({
  commentId,
  isReplyFormVisible,
  handleReplyFormToggle,
  nodeAuthorId,
  replies,
  replyCommentForm,
  userCommentedText
}) => {
  // generate comment's replies section:
  //   1. a list of all replies (if any)
  //   2. "Reply to this comment..." link that toggles the reply form
  //   3. the actual reply CommentForm
  const repliesList = replies.map((reply, index) => {
    return <Comment 
      key={"comment-reply-" + index}
      comment={reply} 
      nodeAuthorId={nodeAuthorId}
      userCommentedText={userCommentedText} 
    />;
  });

  const replyToggleLink = <p
    id={"comment-" + commentId + "-reply-toggle"}
    onClick={handleReplyFormToggle}
    style={{
      color: "#006dcc",
      cursor: "pointer",
      userSelect: "none"
    }}
  >
    Reply to this comment...
  </p>;
  {/* placeholder: link to login if no currentUser */}

  const replyForm = isReplyFormVisible ?
    replyCommentForm :
    "";

  return (
    <>
      {repliesList}
      {replyToggleLink}
      {replyForm}
    </>
  );
}

CommentReplies.propTypes = {
  commentId: PropTypes.number,
  isReplyFormVisible: PropTypes.bool,
  handleReplyFormToggle: PropTypes.func,
  nodeAuthorId: PropTypes.number,
  replies: PropTypes.array,
  userCommentedText: PropTypes.string
}

export default CommentReplies;
