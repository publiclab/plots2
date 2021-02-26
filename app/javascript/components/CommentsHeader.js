import React from "react";
import PropTypes from "prop-types";

const CommentsHeader = ({
  comments,
  commentsHeaderText
}) => {
  let numberOfComments = comments.length;
  let numberOfReplies = 0;
  // comments.length only counts comments, not replies to comments.
  // comment replies are nested within the body of { comment }
  // iterate over each comment to count its replies
  for (let i = 0; i < comments.length; i++) {
    numberOfReplies += comments[i].replies.length;
  }
  numberOfComments += numberOfReplies;

  return (
    <h3> 
      <span id="comment-count">
        {numberOfComments + " " + commentsHeaderText}
      </span>
    </h3>
  );
}

CommentsHeader.propTypes = {
  comments: PropTypes.array,
  commentsHeaderText: PropTypes.string
};

export default CommentsHeader;
