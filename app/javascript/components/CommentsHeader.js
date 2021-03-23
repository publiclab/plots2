import React from "react";
import PropTypes from "prop-types";

import { StaticPropsContext } from "./static-props-context";

const CommentsHeader = ({
  comments
}) => {
  const numberOfComments = comments.length;

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
