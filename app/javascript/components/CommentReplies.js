import React from "react";
import PropTypes from "prop-types";

import Comment from "./Comment";

const CommentReplies = ({
  commentId,
  isReplyFormVisible,
  handleReplyFormToggle,
  replies,
  replyCommentForm,
  setTextAreaValues
}) => {
  // generate comment's replies section:
  //   1. a list of all replies (if any)
  //   2. "Reply to this comment..." link that toggles the reply form
  //   3. the actual reply CommentForm
  const repliesList = replies.map((reply, index) => {
    return <Comment 
      key={"comment-reply-" + index}
      comment={reply} 
      deleteButton={reply.deleteButton}
      isEditFormVisible={reply.isEditFormVisible}
      editCommentForm={reply.editCommentForm}
      setTextAreaValues={setTextAreaValues}
      toggleEditButton={reply.toggleEditButton}
    />;
  });

  const replyToggleLink = <p
    id={"comment-" + commentId + "-reply-toggle"}
    onClick={() => handleReplyFormToggle("reply-" + commentId)}
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
  replies: PropTypes.array.isRequired,
  replyCommentForm: PropTypes.element,
  setTextAreaValues: PropTypes.func.isRequired
}

export default CommentReplies;
