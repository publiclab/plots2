import React from "react";
import PropTypes from "prop-types";

const CommentToolbarButton = ({
  icon
}) => {
  return (
    <a className="btn btn-outline-secondary btn-sm">
      {icon}
    </a>
  );
}

export default CommentToolbarButton;
