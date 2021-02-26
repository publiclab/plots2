import React from "react";
import PropTypes from "prop-types";

const CommentAuthorSection = ({
  authorPicFilename,
  authorUsername,
  authorPicUrl,
  commentName
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
  authorSection = authorSection.concat([authorProfilePic, authorName]);

  return (
    authorSection
  );
}

export default CommentAuthorSection;
