import React from "react";
import PropTypes from "prop-types";

import Comment from "./Comment";
import CommentForm from "./CommentForm";

const CommentsList = ({
  comments,
  elementText: {
    commentFormPlaceholder,
    commentPreviewText,
    commentPublishText,
    userCommentedText
  },
  handleFormSubmit,
  handleTextAreaChange,
  nodeAuthorId,
  nodeId,
  setTextAreaValues,
  textAreaValues
}) => {
  let commentTextAreaValues = {};

  // iterate over comments prop containing all node comments.
  // create a Comment component containing 1-3 CommentForms.
  const commentsList = comments.map((comment, index) => {
    const commentFormProps = {
      commentPreviewText,
      commentPublishText,
      handleFormSubmit,
      handleTextAreaChange,
      nodeId
    };

    // comment forms' textAreaValues is derived from CommentsContainer's state
    // this object is used to hold textAreaValues for a comment's:
    //   1. reply comment form (optional)
    //   2. edit comment form
    //   3. edit comment forms for comment's replies (optional)
    let newTextAreaValues = {}

    // each comment comes with in a edit comment form
    const editFormId = "edit-" + comment.commentId;
    newTextAreaValues[editFormId] = comment.rawCommentText;

    // if the comment is a reply to another comment, DON'T render a reply form.
    // otherwise, the comment can accept replies
    let replyCommentForm = null;
    if (!comment.replyTo) {
      const replyFormId = "reply-" + comment.commentId;
      newTextAreaValues[replyFormId] = "";
      replyCommentForm = <CommentForm
        commentId={comment.commentId}
        commentFormPlaceholder={commentFormPlaceholder}
        commentFormType="reply"
        formId={replyFormId}
        textAreaValue={textAreaValues[replyFormId]}
        {...commentFormProps}
      />;
    }

    // generate the replies' edit comment forms to avoid the alternative: passing down props two levels
    const repliesWithEditForms = comment.replies.map((reply) => {
      const replyEditFormId = "edit-" + reply.commentId;
      // comment form's textAreaValue is derived from CommentsContainer's state
      newTextAreaValues[replyEditFormId] = reply.rawCommentText;

      reply.editCommentForm = <CommentForm 
        commentFormType="edit"
        commentId={reply.commentId}
        formId={replyEditFormId}
        rawCommentText={reply.rawCommentText}
        textAreaValue={textAreaValues[replyEditFormId]}
        {...commentFormProps}
      />;
    });

    const editCommentForm = <CommentForm 
      commentFormType="edit"
      commentId={comment.commentId}
      formId={editFormId}
      textAreaValue={textAreaValues[editFormId]}
      {...commentFormProps}
    />;

    commentTextAreaValues = {...textAreaValues, ...newTextAreaValues};

    return <Comment 
      key={"comment-" + index} 
      comment={comment}
      editCommentForm={editCommentForm}
      nodeAuthorId={nodeAuthorId}
      replyCommentForm={replyCommentForm}
      replies={repliesWithEditForms}
      userCommentedText={userCommentedText} 
    />;
  });

  setTextAreaValues(commentTextAreaValues);

  return (
    <div id="comments-list" style={{ marginBottom: "50px" }}>
      {commentsList}
    </div>
  );
};

CommentsList.propTypes = {
  comments: PropTypes.array.isRequired,
  elementText: PropTypes.object.isRequired,
  handleFormSubmit: PropTypes.func.isRequired,
  handleTextAreaChange: PropTypes.func.isRequired,
  nodeAuthorId: PropTypes.number.isRequired,
  nodeId: PropTypes.number.isRequired,
  setTextAreaValues: PropTypes.func.isRequired,
  textAreaValues: PropTypes.object.isRequired
};

export default CommentsList;
