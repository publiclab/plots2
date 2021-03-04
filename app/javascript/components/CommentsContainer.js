/* eslint-disable complexity */
import React, { useState } from "react";
import PropTypes from "prop-types";

import { UserContext } from "./user-context";
import { StaticPropsContext } from "./static-props-context";
import { 
  getEditTextAreaValues, 
  getInitialCommentFormToggleState, 
  makeDeepCopy 
} from "./helpers";

import CommentForm from "./CommentForm";
import CommentsHeader from "./CommentsHeader";
import CommentsList from "./CommentsList"

const CommentsContainer = ({
  // ES6 destructure the props
  // so we can simply refer to initialComments instead of this.props.initialComments
  initialComments,
  currentUser,
  elementText,
  node,
  node: {
    nodeId
  }
}) => {
  // React Hook: Comments State
  const [comments, setComments] = useState(initialComments);

  // React Hook: Visibility for Reply and Edit Comment Forms
  const initialCommentFormToggleState = getInitialCommentFormToggleState(initialComments);
  const [commentFormsVisibility, setCommentFormsVisibility] = useState(initialCommentFormToggleState);

  // React Hook: <textarea> input state
  // the initial state needs to include default values for edit coment forms
  // if a user opens an edit comment form, it should contain the already existing comment text to be edited
  const initialTextAreaValues = { "main": "", ...getEditTextAreaValues(initialComments) };
  // textAreaValues is an object that holds multiple text forms, eg:
  //   { main: "foo", reply-123: "bar" }
  const [textAreaValues, setTextAreaValues] = useState(initialTextAreaValues);

  const handleDeleteComment = (commentId) => {
    $.get(
      "/comment/delete/" + commentId,
      {
        id: commentId,
        react: true
      },
      function(data) {
        console.log(data);
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

  const handleFormVisibilityToggle = (commentFormId) => {
    setCommentFormsVisibility(oldState => (Object.assign({}, oldState, { [commentFormId]: !oldState[commentFormId] })));
  }

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
          // if the freshly updated comment is a reply, it needs to be nested within comment.replies
          if (data.comment[0].replyTo) {
            for (let i = 0; i < comments.length; i++) {
              // find the comment's parent
              if (comments[i].commentId === data.comment[0].replyTo) {
                let newParent = makeDeepCopy(comments[i]); // make a copy of the parent comment
                for (let j = 0; j < comments[i].replies.length; j++) {
                  // find comment inside parent's replies
                  if (comments[i].replies[j].commentId === data.comment[0].commentId) {
                    let updatedComment = makeDeepCopy(comments[i].replies[j]);
                    updatedComment.htmlCommentText = data.comment[0].htmlCommentText; // update comment text
                    updatedComment.rawCommentText = data.comment[0].rawCommentText;
                    newParent.replies = Object.assign([], newParent.replies, { [j]: updatedComment });
                    // React sometimes fails to update state if it doesn't think that newState is different.
                    // if newState is a deeply nested array like comments, React will have difficulty registering changes.
                    // this is weird syntax, but it addresses the issue.
                    // basically it keeps oldComments (this seems integral to React registering changes), but replaces the comment at index i with newComment.
                    setComments(oldComments => (Object.assign([], oldComments, {[i]: newParent}))); // update state
                    break;
                  }
                }
              }
            }
          } else {
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
          }
          // close the edit comment form
          setCommentFormsVisibility(oldState => (Object.assign({}, oldState, { [formId]: false })));
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
          // blank out the value of textarea
          setTextAreaValues(oldState => ({ ...oldState, [formId]: "" }));
          // close the comment form
          if (formType !== "main") {
            setCommentFormsVisibility(oldState => (Object.assign({}, oldState, { [formId]: false })));
          }
        }
      );
    }
  }

  return (
    // React Context ensures that all components below this one can access the currentUser prop object.
    <UserContext.Provider value={currentUser}>
      <StaticPropsContext.Provider value={{ node, elementText }}>
        <div id="legacy-editor-container" className="row">
          <div id="comments" className="col-lg-10 comments">
            <CommentsHeader comments={comments} />
            <CommentsList 
              commentFormsVisibility={commentFormsVisibility}
              comments={comments}
              handleDeleteComment={handleDeleteComment}
              handleFormVisibilityToggle={handleFormVisibilityToggle}
              handleFormSubmit={handleFormSubmit}
              handleTextAreaChange={handleTextAreaChange}
              setTextAreaValues={setTextAreaValues}
              textAreaValues={textAreaValues}
            />
            {/* main comment form */}
            <CommentForm 
              commentFormType="main" 
              formId="main"
              handleFormSubmit={handleFormSubmit}
              handleTextAreaChange={handleTextAreaChange}
              textAreaValue={textAreaValues["main"]}
            />
          </div>
        </div>
      </StaticPropsContext.Provider>
    </UserContext.Provider>
  );
}

CommentsContainer.propTypes = {
  currentUser: PropTypes.object,
  elementText: PropTypes.object.isRequired,
  initialComments: PropTypes.array.isRequired,
  node: PropTypes.object.isRequired
};

export default CommentsContainer;
