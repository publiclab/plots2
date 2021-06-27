import React from "react";
import PropTypes from "prop-types";

const CommentReplies = ({
  children,
  commentId,
  dispatch,
  isReplyFormVisible,
  replyCommentForm
}) => {
  const replyToggleLink = <p
    id={"comment-" + commentId + "-reply-toggle"}
    onClick={() => dispatch({
      type: "TOGGLE COMMENT FORM VISIBILITY",
      commentFormId: "reply-" + commentId
    })}
    style={{
      color: "#006dcc",
      cursor: "pointer",
      userSelect: "none"
    }}
  >
    Reply to this comment...
  </p>;

  const replyForm = isReplyFormVisible ?
    replyCommentForm :
    "";

  return (
    <>
      {children}
      {replyToggleLink}
      {replyForm}
    </>
  );
}

CommentReplies.propTypes = {
  children: PropTypes.array,
  commentId: PropTypes.number.isRequired,
  dispatch: PropTypes.func.isRequired,
  isReplyFormVisible: PropTypes.bool.isRequired,
  handleReplyFormToggle: PropTypes.func,
  replyCommentForm: PropTypes.element
}

export default CommentReplies;
