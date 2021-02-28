import React, { useState } from "react";
import PropTypes from "prop-types";

import { UserContext } from "./user-context";

import CommentAuthorSlug from "./CommentAuthorSlug.js";
import CommentReplies from "./CommentReplies.js";
import CommentToolbar from "./CommentToolbar.js";

const Comment = ({
  comment: {
    authorId,
    authorPicUrl,
    authorPicFilename,
    authorUsername,
    commentId,
    commentName,
    htmlCommentText,
    replies,
    replyTo,
    timeCreatedString
  },
  editCommentForm,
  nodeAuthorId,
  replyCommentForm,
  userCommentedText
}) => {
  // React Hook for toggling reply form state
  const [isReplyFormVisible, setIsReplyFormVisible] = useState(false);
  // React Hook for toggling edit form state
  const [isEditFormVisible, setIsEditFormVisible] = useState(false);

  const handleEditFormToggle = () => {
    setIsReplyFormVisible(false);
    setIsEditFormVisible(!isEditFormVisible);
  }

  // this toggles visibility depending on isEditFormVisible
  const commentDisplay = (user) => {
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
        >
          {htmlCommentText}
          {/* partial has a contain_trimmed_body bit ? */}
          {/* is this a question? post it to the questions page */}
          {/* breakout questions */}
          {/* have you attempted or completed this activity? */}
        </div>
        {/* only comments that DO NOT have a replyTo will have a reply section */}
        {replyTo ?
          "" :
          <CommentReplies 
            commentId={commentId}
            currentUser={user}
            isReplyFormVisible={isReplyFormVisible}
            handleReplyFormToggle={() => setIsReplyFormVisible(!isReplyFormVisible)}
            nodeAuthorId={nodeAuthorId}
            replies={replies}
            replyCommentForm={replyCommentForm}
            userCommentedText={userCommentedText}
          />
        }
        {/* emojis section - can decide which <div> this should nest into, in non-React version, this is right after the closing </div> tag below */}
      </div>
    );
  }

  return (
    // hooks this component up to React Context, so it can access currentUser object.
    // see CommentsContainer.js
    <UserContext.Consumer>
      {currentUser => (
        <div
          id={"c" + commentId}
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
            <div className="navbar-text float-left">
              <CommentAuthorSlug 
                authorPicFilename={authorPicFilename}
                authorUsername={authorUsername}
                authorPicUrl={authorPicUrl}
                commentName={commentName}
              />
              <span className="d-none d-md-inline">{" " + userCommentedText}</span>
              <a style={{ color: "#aaa" }} href={"#c" + commentId}>
                {" " + timeCreatedString}
              </a>
            </div>
            <CommentToolbar 
              authorId={authorId} 
              currentUser={currentUser} 
              handleEditFormToggle={handleEditFormToggle}
              nodeAuthorId={nodeAuthorId}
            />
          </div>
          {isEditFormVisible ?
            editCommentForm :
            commentDisplay(currentUser)
          }
        </div>
      )}
    </UserContext.Consumer>
  );
}

Comment.propTypes = {
  comment: PropTypes.object.isRequired,
  editCommentForm: PropTypes.element.isRequired,
  nodeAuthorId: PropTypes.number.isRequired,
  replyCommentForm: PropTypes.element,
  userCommentedText: PropTypes.string.isRequired
};

export default Comment;
