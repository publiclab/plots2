import React from "react";
import PropTypes from "prop-types";

import  { UserContext } from "./user-context";
import Comment from "./Comment";
import CommentForm from "./CommentForm";

class CommentsContainer extends React.Component {
  render() {
    const {
      comments,
      commentsHeaderText,
      currentUser,
      nodeAuthorId,
      nodeId,
      userCommentedText
    } = this.props;

    const commentsList = comments.map((comment, index) => {
      const replyCommentForm = comment.replyTo ?
      null :
      <CommentForm
        commentId={comment.commentId}
        commentFormType="reply"
        nodeId={nodeId}
      />;

      return <Comment 
        key={index} 
        comment={comment} 
        nodeAuthorId={nodeAuthorId}
        replyCommentForm={replyCommentForm}
        userCommentedText={userCommentedText} 
      />;
    })

    return (
      <UserContext.Provider value={currentUser}>
        <div id="legacy-editor-container" className="row">
          <div id="comments" className="col-lg-10 comments">
            <h3>
              <span id="comment-count">
                {comments.length + " " + commentsHeaderText}
              </span>
            </h3>
            <div id="comments-list" style={{ marginBottom: "50px" }}>
              {commentsList}
            </div>
            <CommentForm commentFormType="main" nodeId={nodeId} />
          </div>
        </div>
      </UserContext.Provider>
    );
  }
}

CommentsContainer.propTypes = {
  comments: PropTypes.array,
  commentsHeaderText: PropTypes.string,
  nodeAuthorId: PropTypes.number,
  nodeId: PropTypes.number,
  userCommentedText: PropTypes.string
};

export default CommentsContainer;
