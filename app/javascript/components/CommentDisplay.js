import React from "react";
import PropTypes from "prop-types";

import CommentReplies from "./CommentReplies.js";

// this component swaps visibility with edit form depending on isEditFormVisible, see Comment.js
const CommentDisplay = ({
  children,
  commentId,
  htmlCommentText,
  replyTo
}) => {

  return (
    <div
      id={"c" + commentId + "show"}
      style={{
        border: "1px solid #e7e7e7",
        padding: "36px"
      }}
    >
      <div 
        id={"comment-body-" + commentId} 
        className="comment-body"
        // dangerously set HTML so that rich text tags like <b>, <i> will display as HTML
        dangerouslySetInnerHTML={{ __html: htmlCommentText }} // see React docs, there can be some security risk with doing this in general, probably doesn't apply here
        style={{ 
          marginTop: "1rem",
          paddingBottom: !replyTo && "16px" // puts a little buffer in between main comment and its replies
        }} 
      >
        {/* partial has a contain_trimmed_body bit ? */}
        {/* is this a question? post it to the questions page */}
        {/* breakout questions */}
        {/* have you attempted or completed this activity? */}
      </div>
      {/* only comments that DO NOT have a replyTo will have a reply section */}
      {replyTo ?
        "" :
        children // this is the reply section, passed down from CommentsList.js
      }
      {/* emojis section - can decide which <div> this should nest into, in non-React version, this is right after the closing </div> tag below */}
    </div>
  );
}

CommentDisplay.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.array,
    PropTypes.element
  ]),
  commentId: PropTypes.number.isRequired,
  htmlCommentText: PropTypes.string.isRequired,
  replyTo: PropTypes.number
}

export default CommentDisplay;
