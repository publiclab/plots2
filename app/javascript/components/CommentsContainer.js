/* eslint-disable complexity */
import React, { useState } from "react";
import PropTypes from "prop-types";

import  { UserContext } from "./user-context";
import { getEditTextAreaValues, makeDeepCopy } from "./helpers";
import CommentForm from "./CommentForm";
import CommentsHeader from "./CommentsHeader";
import CommentsList from "./CommentsList"

const CommentsContainer = ({
  // ES6 destructure the props
  // so we can simply refer to initialComments instead of this.props.initialComments
  initialComments,
  currentUser,
  elementText,
  elementText: {
    commentFormPlaceholder,
    commentsHeaderText,
    commentPreviewText,
    commentPublishText
  },
  nodeAuthorId,
  nodeId
}) => {
  // React Hook for comments state
  const [comments, setComments] = useState(initialComments);

  // React Hook managing textarea input state 
  // the initial state needs to include default values for edit coment forms
  // if a user opens an edit comment form, it should contain the already existing comment text to be edited
  const initialTextAreaValues = { "main": "", ...getEditTextAreaValues(comments) };
  // textAreaValues is an object that holds multiple text forms, eg:
  //   { main: "foo", reply-123: "bar" }
  const [textAreaValues, setTextAreaValues] = useState(initialTextAreaValues);

  // function for handling user input into comment form <textarea>s
  const handleTextAreaChange = (event) => {
    const value = event.target.value;
    const formId = event.target.dataset.formId // eg. "main", "reply-123", "edit-432"
    // keep the old state values (as ...state) and insert the new one
    setTextAreaValues(state => ({ ...state, [formId]: value }));
  }

  // comment form submission
  const handleFormSubmit = (event) => {
    event.preventDefault();
    const commentId = event.target.dataset.commentId;
    const formType = event.target.dataset.formType;
    const formId = event.target.dataset.formId;
    const commentBody = textAreaValues[formId];

    if (formType === "edit") {
      $.post(
        "/comment/update/" + commentId,
        {
          id: commentId,
          body: commentBody,
          react: true
        }, 
        function(data) {
          console.log(data);
          // if the freshly posted comment is a reply, it needs to be nested within comment.replies
          if (data.comment[0].replyTo) {
            for (let i = 0; i < comments.length; i++) {
              // find the comment with the matching replyTo
              if (comments[i].commentId === data.comment[0].replyTo) {
                let newParent = makeDeepCopy(comments[i]); // make a copy of the parent comment
                for (let j = 0; j < comments[i].replies.length; j++) {
                  let updatedComment = makeDeepCopy(comments[i].replies[j]);
                  updatedComment.htmlCommentText = data.comment[0].htmlCommentText;
                  updatedComment.rawCommentText = data.comment[0].rawCommentText;
                  newParent.replies = Object.assign([], newParent.replies, {j: updatedComment});
                  // React sometimes fails to update state if it doesn't think that newState is different.
                  // if newState is a deeply nested array like comments, React will have difficulty registering changes.
                  // this is weird syntax, but it addresses the issue.
                  // basically it keeps oldComments (this seems integral to React registering changes), but replaces the comment at index i with newComment.
                  setComments(oldComments => (Object.assign([], oldComments, {i: newParent})));
                  break;
                }
              }
            }
          } else {
            for (let i = 0; i < comments.length; i++) {
              if (comments[i].commentId === data.comment[0].commentId) {
                let newComment = makeDeepCopy(comments[i]);
                newComment.htmlCommentText = data.comment[0].htmlCommentText;
                newComment.rawCommentText = data.comment[0].rawCommentText;
                // keep most of oldComments, but replace the comment at index i with newComment.
                setComments(oldComments => (Object.assign([], oldComments, {i: newComment})));
                break;
              }
            }
          }
          notyNotification('mint', 3000, 'success', 'topRight', 'Comment Updated!');
        }
      );
    } else {
      $.post(
        "/comment/create/" + nodeId, 
        {
          body: commentBody,
          id: nodeId,
          react: true,
          reply_to: formType === "reply" ? commentId : null
        },
        function(data) {
          // if the freshly posted comment is a reply, it needs to be nested within comment.replies
          if (data.comment[0].replyTo) {
            for (let i = 0; i < comments.length; i++) {
              // find the comment with the matching replyTo
              if (comments[i].commentId === data.comment[0].replyTo) {
                let newComment = makeDeepCopy(comments[i]);
                newComment.replies.push(data.comment[0]);
                // keep most of oldComments, but replace the comment at index i with newComment.
                setComments(oldComments => (Object.assign([], oldComments, {i: newComment})));
                break;
              }
            }
          // if the freshly posted comment is NOT a reply, just push it into the comments state as is
          } else {
            setComments(oldComments => ([...oldComments, data.comment[0]]));
          }
          notyNotification('mint', 3000, 'success', 'topRight', 'Comment Added!');
        }
      );
    }
  }

  return (
    // React Context ensures that all components below this one can access the currentUser prop object.
    <UserContext.Provider value={currentUser}>
      <div id="legacy-editor-container" className="row">
        <div id="comments" className="col-lg-10 comments">
          <CommentsHeader comments={comments} commentsHeaderText={commentsHeaderText} />
          <CommentsList 
            comments={comments}
            elementText={elementText}
            handleFormSubmit={handleFormSubmit}
            handleTextAreaChange={handleTextAreaChange}
            nodeAuthorId={nodeAuthorId}
            nodeId={nodeId}
            setTextAreaValues={setTextAreaValues}
            textAreaValues={textAreaValues}
          />
          {/* main comment form */}
          <CommentForm 
            commentFormPlaceholder={commentFormPlaceholder}
            commentFormType="main" 
            commentPreviewText={commentPreviewText}
            commentPublishText={commentPublishText}
            formId="main"
            handleFormSubmit={handleFormSubmit}
            handleTextAreaChange={handleTextAreaChange}
            nodeId={nodeId} 
            textAreaValue={textAreaValues["main"]}
          />
        </div>
      </div>
    </UserContext.Provider>
  );
}

CommentsContainer.propTypes = {
  currentUser: PropTypes.object,
  elementText: PropTypes.object,
  initialComments: PropTypes.array.isRequired,
  nodeAuthorId: PropTypes.number,
  nodeId: PropTypes.number
};

export default CommentsContainer;
