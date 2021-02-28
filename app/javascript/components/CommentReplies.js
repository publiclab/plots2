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
  setTextAreaValues,
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
      editCommentForm={reply.editCommentForm}
      nodeAuthorId={nodeAuthorId}
      setTextAreaValues={setTextAreaValues}
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
  // placeholder: link to login if no currentUser

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
  commentId: PropTypes.number.isRequired,
  isReplyFormVisible: PropTypes.bool.isRequired,
  handleReplyFormToggle: PropTypes.func,
  nodeAuthorId: PropTypes.number.isRequired,
  replies: PropTypes.array.isRequired,
  replyCommentForm: PropTypes.element,
  setTextAreaValues: PropTypes.func.isRequired,
  userCommentedText: PropTypes.string.isRequired
}

export default CommentReplies;
