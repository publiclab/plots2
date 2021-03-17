import React, { useState } from "react";
import PropTypes from "prop-types";

import { UserContext } from "./user-context";
import { makeDeepCopy } from "./helpers";

import CommentForm from "./CommentForm";
import CommentsHeader from "./CommentsHeader";
import CommentsList from "./CommentsList"

const CommentsContainer = ({
  initialCommentFormToggleState,
  initialComments,
  initialTextAreaValues,
  nodeId
}) => {
  // React Hook: Comments State
  const [comments, setComments] = useState(initialComments);

  // React Hook: Visibility for Reply and Edit Comment Forms
  const [commentFormsVisibility, setCommentFormsVisibility] = useState(initialCommentFormToggleState);

  // hide and reveal reply & edit comment forms
  const handleFormVisibilityToggle = (commentFormId) => {
    setCommentFormsVisibility(oldState => (Object.assign({}, oldState, { [commentFormId]: !oldState[commentFormId] })));
  }

  // React Hook: <textarea> Input State for Comment Forms
  //   ie. the value that shows inside a comment form's <textarea>
  //   main and reply contain empty strings
  //   edit forms contain the raw comment text to be edited
  const [textAreaValues, setTextAreaValues] = useState(initialTextAreaValues);

  // function for handling user input into comment form <textarea>s
  const handleTextAreaChange = (event) => {
    const value = event.target.value;
    const formId = event.target.dataset.formId // eg. "main", "reply-123", "edit-432"
    // keep the old state values (as ...state) and insert the new one
    setTextAreaValues(state => ({ ...state, [formId]: value }));
  }

  // Functions for Creating, Updating, Deleting Comments

  const handleCreateComment = (commentId, formType) => {
    // form ID is either reply-123 or main
    const formId = formType === "reply" ? "reply-" + commentId : "main";
    const commentBody = textAreaValues[formId];

    $.post(
      "/comment/create/" + nodeId, 
      {
        body: commentBody,
        id: nodeId,
        react: true,
        reply_to: formType === "reply" ? commentId : null
      },
      function(data) {
        notyNotification('mint', 3000, 'success', 'topRight', 'Comment Added!');
        const newCommentId = data.comment[0].commentId;
        const newCommentRawText = data.comment[0].rawCommentText;
        // blank out the value of textarea & also create a value for the new comment's edit form
        setTextAreaValues(oldState => ({ ...oldState, [formId]: "", ["edit-" + newCommentId]: newCommentRawText }));
        // the new comment form comes with an edit form, its toggle state needs to be created as well
        setCommentFormsVisibility(oldState => ({ ...oldState, ["edit-" + newCommentId]: false }));
        // if the comment doesn't have a replyTo, then it's a parent comment
        // parent comments have reply forms, this needs to be set in state as well.
        if (!data.comment[0].replyTo) {
          setCommentFormsVisibility(oldState => ({ ...oldState, ["reply-" + newCommentId]: false }));
        }
        // push the comment into state
        setComments(oldComments => ([...oldComments, data.comment[0]]));
        // close the comment form
        if (formType !== "main") {
          setCommentFormsVisibility(oldState => (Object.assign({}, oldState, { [formId]: false })));
        }
      }
    );
  }

  const handleUpdateComment = (commentId, formType) => {
    const formId = "edit-" + commentId;
    const commentBody = textAreaValues[formId];

    $.post(
      "/comment/update/" + commentId,
      {
        id: commentId,
        body: commentBody,
        react: true
      }, 
      function(data) {
        // the freshly updated comment is NOT a reply
        for (let i = 0; i < comments.length; i++) {
          // find the comment in state
          if (comments[i].commentId === data.comment[0].commentId) {
            let newComment = makeDeepCopy(comments[i]);
            newComment.htmlCommentText = data.comment[0].htmlCommentText; // update comment text
            newComment.rawCommentText = data.comment[0].rawCommentText;
            // keep most of oldComments, but replace the comment at index i with newComment.
            setComments(oldComments => (Object.assign([], oldComments, { [i]: newComment })));
            break;
          }
        }
        // close the edit comment form
        setCommentFormsVisibility(oldState => (Object.assign({}, oldState, { [formId]: false })));
        notyNotification('mint', 3000, 'success', 'topRight', 'Comment Updated!');
      }
    );
  }

  const handleDeleteComment = (commentId) => {
    $.get(
      "/comment/delete/" + commentId,
      {
        id: commentId,
        react: true
      },
      function(data) {
        if (data.success) {
          for (let i = 0; i < comments.length; i++) {
            if (comments[i].commentId === commentId) {
              setComments(oldState => (oldState.filter(comment => comment.commentId !== commentId)));
              notyNotification('sunset', 3000, 'error', 'topRight', 'Comment deleted');
            }
          }
        }
      }
    )
  }

  return (
    <UserContext.Consumer>
      {currentUser => (
        <div id="legacy-editor-container" className="row">
          <div id="comments" className="col-lg-10 comments">
            <CommentsHeader comments={comments} />
            <CommentsList 
              commentFormsVisibility={commentFormsVisibility}
              comments={comments}
              currentUser={currentUser}
              handleCreateComment={handleCreateComment}
              handleDeleteComment={handleDeleteComment}
              handleFormVisibilityToggle={handleFormVisibilityToggle}
              handleTextAreaChange={handleTextAreaChange}
              handleUpdateComment={handleUpdateComment}
              setTextAreaValues={setTextAreaValues}
              textAreaValues={textAreaValues}
            />
            {/* main comment form */}
            <CommentForm 
              commentFormType="main" 
              formId="main"
              handleFormSubmit={handleCreateComment}
              handleTextAreaChange={handleTextAreaChange}
              textAreaValue={textAreaValues["main"]}
            />
          </div>
        </div>
      )}
    </UserContext.Consumer>
  );
}

CommentsContainer.propTypes = {
  initialCommentFormToggleState: PropTypes.object.isRequired,
  initialComments: PropTypes.array.isRequired,
  initialTextAreaValues: PropTypes.object.isRequired,
  nodeId: PropTypes.number.isRequired
};

export default CommentsContainer;
