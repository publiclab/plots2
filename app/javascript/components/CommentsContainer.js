import React from "react";
import PropTypes from "prop-types";

import CommentForm from "./CommentForm";
import Comment from "./Comment";

class CommentsContainer extends React.Component {
  
  render() {
    const comments = this.props.comments.map((comment, index) => <Comment key={index} comment={comment} />);

    return (
      <div id="legacy-editor-container" className="row">
        <div id="comments" className="col-lg-10 comments">
          <h3>
            <span id="comment-count">
              {comments.length + " " + this.props.commentsHeaderText}
            </span>
          </h3>
          <div id="comments-list" style={{ marginBottom: "50px" }}>
            {comments}
          </div>
        </div>
        <CommentForm location="main" />
      </div>
    );
  }
}

CommentsContainer.propTypes = {
  comments: PropTypes.array,
  commentsHeaderText: PropTypes.string
};

export default CommentsContainer;
