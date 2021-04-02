import React from "react";
import PropTypes from "prop-types";

const CommentToolbarButton = ({
  icon,
  onClick
}) => {
  return (
    <a 
      className="btn btn-outline-secondary btn-sm"
      onClick={onClick}
    >
      {icon}
    </a>
  );
}

CommentToolbarButton.propTypes = {
  icon: PropTypes.element,
  onClick: PropTypes.func
};

export default CommentToolbarButton;
