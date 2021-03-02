import React from "react";
import PropTypes from "prop-types";

const CommentForm = ({
  commentFormPlaceholder,
  commentFormType,
  commentId,
  commentPreviewText,
  commentPublishText,
  formId,
  handleFormSubmit,
  handleTextAreaChange,
  textAreaValue
}) => {

  // comment form's title text
  let formTitle = "Post Comment";
  if (commentFormType === "edit") {
    formTitle = "Edit Comment";
  } else if (commentFormType === "reply") {
    formTitle = "Reply to This Comment";
  }

  return (
    <div
      id={"comment-form-wrapper-" + formId}
      className="bg-light card card-body comment-form-wrapper"
      style={{
        backgroundColor: "#f8f8f8",
        border: "1px solid #e7e7e7",
        padding: "36px"
      }}
    >
      {/* data-remote="true" means the form is submitted with AJAX */}
      {/* see https://guides.rubyonrails.org/working_with_javascript_in_rails.html#remote-elements */}
      <form 
        id={"comment-form-" + formId}
        className={commentFormType === "edit" ? "edit-comment-form well" : "comment-form"}
        data-remote="true"
        method="post"
      >
        <h4>{formTitle}</h4>
        {/* placeholder: form_authenticity_token */}
        {/* placeholder: hidden_field_tag :reply_to */}
        <div
          id={"comment-form-body-" + formId}
          className="comment-form-body dropzone dropzone-large form-group"
        >
          {/* placeholder: new contributor message for non-edit form */}
          {/* placeholder: textarea below needs an aria-label attribute*/}
          <textarea
            id={"text-input-" + formId}
            className="form-control text-input"
            data-form-id={formId}
            name="body"
            cols="40"
            onChange={handleTextAreaChange}
            rows="6"
            style={{
              border: "1px solid #bbb",
              borderBottom: 0,
              borderBottomLeftRadius: 0,
              borderBottomRightRadius: 0,
              padding: "10px"
            }}
            placeholder={commentFormPlaceholder}
            value={textAreaValue}
          ></textarea>
          {/* placeholder: image upload elements */}
        </div>
        {/* placeholder: comment preview section */}
        <div className="control-group">
          <button
            className="btn btn-primary"
            data-comment-id={commentId}
            data-form-id={formId}
            data-form-type={commentFormType}
            onClick={handleFormSubmit}
          >
            {commentPublishText}
          </button>
          &nbsp;
          <a
            id={"toggle-preview-button-" + formId}
            className="btn btn-default btn-outline-secondary preview-btn"
          >
            {commentPreviewText}
          </a>
        </div>
      </form>
    </div>
  );
}

CommentForm.propTypes = {
  commentId: PropTypes.number,
  commentFormPlaceholder: PropTypes.string,
  commentFormType: PropTypes.string.isRequired,
  commentPreviewText: PropTypes.string.isRequired,
  commentPublishText: PropTypes.string.isRequired,
  formId: PropTypes.string.isRequired,
  handleFormSubmit: PropTypes.func.isRequired,
  handleTextAreaChange: PropTypes.func.isRequired,
  textAreaValue: PropTypes.string
};

export default CommentForm;
