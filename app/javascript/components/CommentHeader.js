import React from "react";
import PropTypes from "prop-types";

import { StaticPropsContext } from "./static-props-context";

const CommentHeader = ({
  authorPicFilename,
  authorUsername,
  authorPicUrl,
  commentId,
  commentName,
  timeCreatedString
}) => {
  // top-left comment author information
  let authorSection = [];
  // author's profile pic, or anonymous blank circle
  const authorProfilePic = (authorPicFilename) ? 
    <img
      className="rounded-circle"
      alt="Comment Author Profile Picture"
      src={authorPicUrl}
      style={{
        marginRight: "6px",
        width: "32px"
      }}
    /> :
    <div 
      className="rounded-circle" 
      style={{
        background: "#ccc", 
        display: "inline-block", 
        height: "32px", 
        marginRight: "6px", 
        verticalAlign: "middle", 
        width: "32px"
      }} 
    ></div>;
    
  const authorName = (authorUsername) ?
    <a href={"/profile/" + authorUsername}>
      {" " + authorUsername}
    </a> :
    commentName;

  return (
    <StaticPropsContext.Consumer>
      {staticProps => (
        <div className="navbar-text float-left">
          {authorProfilePic}
          {authorName}
          <span className="d-none d-md-inline">{" " + staticProps.elementText.userCommentedText}</span>
          <a style={{ color: "#aaa" }} href={"#c" + commentId}>
            {" " + timeCreatedString}
          </a>
        </div>
      )}
    </StaticPropsContext.Consumer>
  );
}

CommentHeader.propTypes = {
  authorPicFilename: PropTypes.string,
  authorUsername: PropTypes.string,
  authorPicUrl: PropTypes.string,
  commentId: PropTypes.number.isRequired,
  commentName: PropTypes.string,
  timeCreatedString: PropTypes.string.isRequired
}

export default CommentHeader;
