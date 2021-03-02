import React from "react";
import PropTypes from "prop-types";

import { StaticPropsContext } from "./static-props-context";

const CommentsHeader = ({
  comments
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
    <StaticPropsContext.Consumer>
      {staticProps => (
        <h3> 
          <span id="comment-count">
            {numberOfComments + " " + staticProps.elementText.commentsHeaderText}
          </span>
        </h3>
      )}
    </StaticPropsContext.Consumer>
  );
}

CommentsHeader.propTypes = {
  comments: PropTypes.array.isRequired
};

export default CommentsHeader;
