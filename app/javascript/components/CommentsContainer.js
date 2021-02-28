import React, { useState } from "react";
import PropTypes from "prop-types";

import  { UserContext } from "./user-context";
import Comment from "./Comment";
import CommentForm from "./CommentForm";
import CommentsHeader from "./CommentsHeader";

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
    commentPublishText,
    userCommentedText
  },
  nodeAuthorId,
  nodeId
}) => {
  // React Hook managing textarea input state 
  const [textAreaValues, setTextAreaValues] = useState({});
  // function for handling user input into comment form <textarea>s
  const handleTextAreaChange = (event) => {
    const value = event.target.value;
    const formId = event.target.dataset.formId // eg. "main", "reply-123", "edit-432"
    // textAreaValues is an object that holds multiple text forms, eg:
    //   { main: "foo", reply-123: "bar" }
    // keep the old state values (as ...state) and insert the new one
    setTextAreaValues(state => ({ ...state, [formId]: value }));
  }

  // React Hook for comments state
  const [comments, setComments] = useState(initialComments);

  // comment form submission
  const handleFormSubmit = (event) => {
    event.preventDefault();
    const formId = event.target.dataset.formId;
    const commentBody = textAreaValues[formId];
    $.post(
      "/comment/create/" + nodeId, 
      {
        body: commentBody,
        id: nodeId,
        react: true,
        reply_to: event.target.dataset.replyTo ? event.target.dataset.replyTo : null
      },
      function(data) {
        let newComments = JSON.parse(JSON.stringify(comments)); // make a deep copy of the comments state

        // if the freshly posted comment is a reply, it needs to be nested within comment.replies
        if (data.comment[0].replyTo) {
          for (let i = 0; i < newComments.length; i++) {
            if (newComments[i].commentId === data.comment[0].replyTo) {
              let newReplies = JSON.parse(JSON.stringify(newComments[i].replies)); // make a deep copy of the comment's replies
              newReplies.push(data.comment[0]);
              newReplies = newReplies.sort((a, b) => b.date - a.date);
              newComments[i].replies = newReplies;
              break;
            }
          }
        } else {
          newComments = JSON.parse(JSON.stringify(comments)); // make a deep copy of the comments state
          newComments.push(data.comment[0]);
          newComments = newComments.sort((a, b) => b.date - a.date);
        }

        setComments(newComments);
      }
    );
  }

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
   
    // if the comment is a reply to another comment, DON'T render a reply form.
    // otherwise, the comment can accept replies
    const replyCommentForm = comment.replyTo ?
    null :
    <CommentForm
      commentId={comment.commentId}
      commentFormPlaceholder={commentFormPlaceholder}
      commentFormType="reply"
      {...commentFormProps}
    />;

    const editCommentForm = <CommentForm 
      commentFormType="edit"
      commentId={comment.commentId}
      rawCommentText={comment.rawCommentText}
      {...commentFormProps}
    />

    // generate the replies' edit comment forms to avoid the alternative:
    //   ie. passing down props two levels
    const repliesWithEditForms = comment.replies.map((reply) => {
      reply.editCommentForm = <CommentForm 
        commentFormType="edit"
        commentId={reply.commentId}
        rawCommentText={comment.rawCommentText}
        {...commentFormProps}
      />;
    });

    return <Comment 
      key={"comment-" + index} 
      comment={comment}
      editCommentForm={editCommentForm}
      nodeAuthorId={nodeAuthorId}
      replyCommentForm={replyCommentForm}
      replies={repliesWithEditForms}
      userCommentedText={userCommentedText} 
    />;
  })

  return (
    // React Context ensures that all components below this one can access the currentUser prop object.
    <UserContext.Provider value={currentUser}>
      <div id="legacy-editor-container" className="row">
        <div id="comments" className="col-lg-10 comments">
          <CommentsHeader comments={comments} commentsHeaderText={commentsHeaderText} />
          <div id="comments-list" style={{ marginBottom: "50px" }}>
            {commentsList}
          </div>
          {/* main comment form */}
          <CommentForm 
            commentFormPlaceholder={commentFormPlaceholder}
            commentFormType="main" 
            commentPreviewText={commentPreviewText}
            commentPublishText={commentPublishText}
            handleFormSubmit={handleFormSubmit}
            handleTextAreaChange={handleTextAreaChange}
            nodeId={nodeId} 
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
