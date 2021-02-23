import React from "react";
import PropTypes from "prop-types";

import  { UserContext } from "./user-context";
import Comment from "./Comment";
import CommentForm from "./CommentForm";

class CommentsContainer extends React.Component {
  render() {
    const {
      comments,
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
    } = this.props;

    const commentsList = comments.map((comment, index) => {
      const replyCommentForm = comment.replyTo ?
      null :
      <CommentForm
        commentId={comment.commentId}
        commentFormPlaceholder={elementText.commentFormPlaceholder}
        commentFormType="reply"
        commentPreviewText={elementText.commentPreviewText}
        commentPublishText={elementText.commentPublishText}
        nodeId={nodeId}
      />;

      return <Comment 
        key={index} 
        comment={comment} 
        nodeAuthorId={nodeAuthorId}
        replyCommentForm={replyCommentForm}
        userCommentedText={elementText.userCommentedText} 
      />;
    })

    return (
      <UserContext.Provider value={currentUser}>
        <div id="legacy-editor-container" className="row">
          <div id="comments" className="col-lg-10 comments">
            <h3>
              <span id="comment-count">
                {comments.length + " " + elementText.commentsHeaderText}
              </span>
            </h3>
            <div id="comments-list" style={{ marginBottom: "50px" }}>
              {commentsList}
            </div>
            <CommentForm 
              commentFormPlaceholder={elementText.commentFormPlaceholder}
              commentFormType="main" 
              commentPreviewText={elementText.commentPreviewText}
              commentPublishText={elementText.commentPublishText}
              nodeId={nodeId} 
            />
          </div>
        </div>
      </UserContext.Provider>
    );
  }
}

CommentsContainer.propTypes = {
  comments: PropTypes.array,
  elementText: PropTypes.object,
  nodeAuthorId: PropTypes.number,
  nodeId: PropTypes.number
};

export default CommentsContainer;
