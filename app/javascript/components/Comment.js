import React from "react";
import PropTypes from "prop-types";

import { UserContext } from "./user-context";
import { StaticPropsContext } from "./static-props-context";

import CommentDisplay from "./CommentDisplay";
import CommentHeader from "./CommentHeader.js";
import CommentToolbar from "./CommentToolbar.js";

const Comment = ({
  children,
  comment: {
    authorId,
    authorPicUrl,
    authorPicFilename,
    authorUsername,
    commentId,
    commentName,
    htmlCommentText,
    timeCreatedString
  },
  deleteButton,
  editCommentForm,
  isEditFormVisible,
  isReplyFormVisible,
  toggleEditButton
}) => {
  return (
    // hooks this component up to React Context, so it can access currentUser object.
    // see CommentsContainer.js
    <UserContext.Consumer>
      {currentUser => (
        <StaticPropsContext.Consumer>
          {staticProps => (
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
                />
                <CommentToolbar 
                  authorId={authorId} 
                  currentUser={currentUser} 
                  deleteButton={deleteButton}
                  nodeAuthorId={staticProps.node.nodeAuthorId}
                  toggleEditButton={toggleEditButton}
                />
              </div>
              {isEditFormVisible ?
                editCommentForm :
                <CommentDisplay
                  commentId={commentId}
                  htmlCommentText={htmlCommentText}
                  isReplyFormVisible={isReplyFormVisible}
                >
                  {children}
                </CommentDisplay>
              }
            </div>
          )}
        </StaticPropsContext.Consumer>
      )}
    </UserContext.Consumer>
  );
}

Comment.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.array,
    PropTypes.element
  ]),
  comment: PropTypes.shape({
  authorId: PropTypes.number.isRequired,
  authorPicUrl: PropTypes.string,
  authorPicFilename: PropTypes.string,
  authorUsername: PropTypes.string.isRequired,
  commentId: PropTypes.number.isRequired,
  commentName: PropTypes.string,
  htmlCommentText: PropTypes.string.isRequired,
  timeCreatedString: PropTypes.string.isRequired
}).isRequired,
  deleteButton: PropTypes.element.isRequired,
  editCommentForm: PropTypes.element.isRequired,
  isEditFormVisible: PropTypes.bool.isRequired,
  isReplyFormVisible: PropTypes.bool,
  toggleEditButton: PropTypes.element.isRequired
};

export default Comment;
