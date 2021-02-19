import React from "react";
import PropTypes from "prop-types";

class Comment extends React.Component {
  render() {
    const {  
      authorPicUrl,
      authorPicFilename,
      authorUsername,
      cid,
      commentName,
      htmlCommentText,
      rawCommentText,
      replies,
      replyTo,
      timeCreatedString
    } = this.props.comment;

    let authorSection = [];
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
    
    let replySection = "";
    if (!replyTo) {
      const repliesList = replies.map((reply, index) => {
        return <Comment key={index} comment={reply} userCommentedText={this.props.userCommentedText} />;
      });
      const replyToggleLink = <p
          id={"comment-" + cid + "-reply-toggle"}
          style={{
            color: "#006dcc",
            cursor: "pointer",
            userSelect: "none"
          }}
        >
          Reply to this comment...
        </p>;
      replySection = [repliesList, replyToggleLink];
    }

    return (
      <div
        id={"c" + cid}
        className="comment"
        style={{
          marginTop: "20px",
          marginBottom: "20px",
          paddingBottom: "9px",
          wordWrap: "break-word"
        }}
      >
        <div
          className="bg-light navbar navbar-light"
          style ={{
            borderBottom: 0,
            borderBottomLeftRadius: 0,
            borderBottomRightRadius: 0,
            marginBottom: 0
          }}
        >
          {/* placeholder: moderator controls for approving comments from first-time posters */}
          <div className="navbar-text float-left d-md-none">&nbsp;&nbsp;</div>
          <div className="navbar-text float-left">
            {authorSection}
            <span className="d-none d-md-inline">{" " + this.props.userCommentedText}</span>
            <a style={{ color: "#aaa" }} href={"#c" + cid}>
              {" " + timeCreatedString}
            </a>
          </div>
          <div
            className="navbar-text float-right"
            style={{
              marginRight: 0,
              paddingRight: "10px"
            }}
          >
            {/* placeholder: role icon for admins and moderators--but it's commented out in the original partial? */}
            {/* placeholder: this comment was posted by email */}
            {/* placeholder: top-right corner buttons (edit, delete, mark as spam, emoji reactions) */}
          </div>
        </div>
        <div
          id={"c" + cid + "show"}
          style={{
            border: "1px solid #e7e7e7",
            padding: "36px"
          }}
        >
          <div 
            id={"comment-body-" + cid} 
            className="comment-body"
          >
            {htmlCommentText}
            {/* partial has a contain_trimmed_body bit ? */}
            {/* is this a question? post it to the questions page */}
            {/* breakout questions */}
            {/* have you attempted or completed this activity? */}
          </div>
          {replySection}
          {/* reply form, or link to login if no currentUser */}
        </div>
        {/* emojis section */}
        {/* edit comment form */}
      </div>
    );
  }
}

Comment.propTypes = {
  comment: PropTypes.object,
  userCommentedText: PropTypes.string
};

export default Comment;
