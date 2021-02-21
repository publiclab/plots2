import React from "react";
import PropTypes from "prop-types";

class CommentForm extends React.Component {
  render() {
    const {
      commentId,
      commentFormType,
      nodeId
    } = this.props;

    // HTML attributes for <form> tag
    const formId = commentFormType === "main" ?
      "main" : 
      commentFormType + "-" + commentId;
    const formClass = commentFormType === "edit" ?
      "edit-comment-form well" : 
      "comment-form";
    const formAction = commentFormType === "edit" ?
      "/update/" + commentId :
      "/create/" + nodeId;

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
          className={formClass}
          action={formAction}
          data-remote="true"
          method="post"
        >
          <h4>{formTitle}</h4>
          This is the comment form.
        </form>
      </div>
    );
  }
}

CommentForm.propTypes = {
  commentId: PropTypes.number,
  commentFormType: PropTypes.string,
  nodeId: PropTypes.number
};

export default CommentForm;
