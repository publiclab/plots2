import React from "react";
import PropTypes from "prop-types";

import Comment from "./Comment";
import CommentForm from "./CommentForm";
import CommentToolbarButton from "./CommentToolbarButton";

const CommentsList = ({
  commentFormsVisibility,
  comments,
  handleDeleteComment,
  handleFormVisibilityToggle,
  handleFormSubmit,
  handleTextAreaChange,
  setTextAreaValues,
  textAreaValues
}) => {
  // iterate over comments prop containing all node comments.
  // create a Comment component containing 1-3 CommentForms.
  const commentsList = comments.map((comment, index) => {
    const commentFormProps = {
      handleFormSubmit,
      handleTextAreaChange
    };

    // every comment at the top level has a reply form
    // comments nested in the second level don't have a reply form
    const replyFormId = "reply-" + comment.commentId;
    const replyCommentForm = <CommentForm
      commentId={comment.commentId}
      commentFormType="reply"
      formId={replyFormId}
      textAreaValue={textAreaValues[replyFormId]}
      {...commentFormProps}
    />;

    // each comment comes with in a edit comment form
    const editFormId = "edit-" + comment.commentId;
    const editCommentForm = <CommentForm 
      commentFormType="edit"
      commentId={comment.commentId}
      formId={editFormId}
      textAreaValue={textAreaValues[editFormId]}
      {...commentFormProps}
    />;

    // each comment comes with a button to toggle edit form visible
    const toggleEditButton = <CommentToolbarButton 
      icon={<i className="fa fa-pencil"></i>}
      onClick={() => handleFormVisibilityToggle("edit-" + comment.commentId)}
    />;

    const deleteButton = <CommentToolbarButton
      icon={<i className='icon fa fa-trash'></i>}
      onClick={() => handleDeleteComment(comment.commentId)}
    />;

    // generate the replies' edit comment forms to avoid the alternative: passing down props two levels
    const repliesWithEditForms = comment.replies.map((reply) => {
      const replyEditFormId = "edit-" + reply.commentId;

      // reply has a button to toggle edit form visible
      const replyToggleEditButton = <CommentToolbarButton
        icon={<i className="fa fa-pencil"></i>}
        onClick={() => handleFormVisibilityToggle(replyEditFormId)}
      />;
      reply.toggleEditButton = replyToggleEditButton;
      reply.isEditFormVisible = commentFormsVisibility[replyEditFormId];

      // delete button
      const replyDeleteButton = <CommentToolbarButton
        icon={<i className='icon fa fa-trash'></i>}
        onClick={() => handleDeleteComment(reply.commentId)}
      />;

      reply.deleteButton = replyDeleteButton;

      // reply has an edit comment form
      reply.editCommentForm = <CommentForm 
        commentFormType="edit"
        commentId={reply.commentId}
        isEditFormVisible={commentFormsVisibility[replyEditFormId]}
        formId={replyEditFormId}
        rawCommentText={reply.rawCommentText}
        textAreaValue={textAreaValues[replyEditFormId]}
        {...commentFormProps}
      />;
    });

    return <Comment 
      key={"comment-" + index} 
      comment={comment}
      deleteButton={deleteButton}
      editCommentForm={editCommentForm}
      handleFormVisibilityToggle={handleFormVisibilityToggle}
      isEditFormVisible={commentFormsVisibility[editFormId]}
      isReplyFormVisible={commentFormsVisibility[replyFormId]}
      replyCommentForm={replyCommentForm}
      replies={repliesWithEditForms}
      setTextAreaValues={setTextAreaValues}
      toggleEditButton={toggleEditButton}
    />;
  });

  return (
    <div id="comments-list" style={{ marginBottom: "50px" }}>
      {commentsList}
    </div>
  );
};

CommentsList.propTypes = {
  commentFormsVisibility: PropTypes.object.isRequired,
  comments: PropTypes.array.isRequired,
  handleDeleteComment: PropTypes.func.isRequired,
  handleFormVisibilityToggle: PropTypes.func.isRequired,
  handleFormSubmit: PropTypes.func.isRequired,
  handleTextAreaChange: PropTypes.func.isRequired,
  setTextAreaValues: PropTypes.func.isRequired,
  textAreaValues: PropTypes.object.isRequired
};

export default CommentsList;
