import React from "react";
import PropTypes from "prop-types";

const CommentToolbarButton = ({
  buttonType,
  icon,
  onClick
}) => {
  let additionalClass;
  
  switch(buttonType) {
    case "edit":
      additionalClass = " edit-comment-btn";
      break;
    case "delete":
      additionalClass = " delete-comment-btn";
      break;
    default:
      additionalClass = "";
  }

  return (
    <a 
      className={"btn btn-outline-secondary btn-sm" + additionalClass}
      onClick={onClick}
    >
      {icon}
    </a>
  );
}

CommentToolbarButton.propTypes = {
  buttonType: PropTypes.string,
  icon: PropTypes.element,
  onClick: PropTypes.func
};

export default CommentToolbarButton;
