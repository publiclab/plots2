import React, { useState } from "react";
import PropTypes from "prop-types";

import { UserContext } from "./user-context";

import CommentDisplay from "./CommentDisplay";
import CommentHeader from "./CommentHeader.js";
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
    rawCommentText,
    replies,
    replyTo,
    timeCreatedString
  },
  editCommentForm,
  nodeAuthorId,
  replyCommentForm,
  setTextAreaValues,
  userCommentedText
}) => {
  // React Hook for toggling reply form state
  const [isReplyFormVisible, setIsReplyFormVisible] = useState(false);
  // React Hook for toggling edit form state
  const [isEditFormVisible, setIsEditFormVisible] = useState(false);

  const handleEditFormToggle = () => {
    setIsReplyFormVisible(false);
    if (isEditFormVisible) {
      setTextAreaValues(state => ({ ...state, ["edit-" + commentId]: rawCommentText }))
    }
    setIsEditFormVisible(!isEditFormVisible);
    // put setTextAreaValues call here
    // textAreaValues needs to include "edit-123: 'raw text'" key value pair
    // then that textAreaValue is passed all the way down here to populate edit comment form's textarea
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
            <CommentHeader 
              authorPicFilename={authorPicFilename}
              authorUsername={authorUsername}
              authorPicUrl={authorPicUrl}
              commentId={commentId}
              commentName={commentName}
              timeCreatedString={timeCreatedString}
              userCommentedText={userCommentedText}
            />
            <CommentToolbar 
              authorId={authorId} 
              currentUser={currentUser} 
              handleEditFormToggle={handleEditFormToggle}
              nodeAuthorId={nodeAuthorId}
            />
          </div>
          {isEditFormVisible ?
            editCommentForm :
            <CommentDisplay
              commentId={commentId}
              htmlCommentText={htmlCommentText}
              isReplyFormVisible={isReplyFormVisible}
              nodeAuthorId={nodeAuthorId}
              replies={replies}
              replyCommentForm={replyCommentForm}
              replyTo={replyTo}
              setIsReplyFormVisible={setIsReplyFormVisible}
              setTextAreaValues={setTextAreaValues}
              user={currentUser}
              userCommentedText={userCommentedText}
            />
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
  setTextAreaValues: PropTypes.func.isRequired,
  userCommentedText: PropTypes.string.isRequired
};

export default Comment;
