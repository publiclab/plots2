/* eslint-disable complexity */
import React from "react";
import PropTypes from "prop-types";

import CommentToolbarButton from "./CommentToolbarButton";

const CommentToolbar = ({
  authorId,
  currentUser,
  deleteButton,
  nodeAuthorId,
  toggleEditButton
}) => {
  // 1. edit button
  const isUserAuthor = currentUser && authorId === currentUser.id;

  // 2. mark spam button (for moderators) OR flag as spam (for all users)
  const markSpamIcon = <i className="fa fa-ban"></i>;
  const flagSpamIcon = <i className="fa fa-flag"></i>;
  const isUserModerator = currentUser && currentUser.canModerate;
  const markSpamButton = isUserModerator ?
    <CommentToolbarButton icon={markSpamIcon} /> :
    <CommentToolbarButton icon={flagSpamIcon} />;
  // original Rails view's conditionals include logged_in_as['admin', 'moderator']
  // don't know if this is completely equivalent to user.canModerate

  // 3. delete comment button
  const isUserNodeAuthor = currentUser && currentUser.id === authorId && authorId === nodeAuthorId;
  const userCanDeleteComment = isUserAuthor || isUserModerator || isUserNodeAuthor;

  // 4. leave an emoji reaction button
  const emojiIcon = <i className='far fa-heart'></i>;
  const emojiButton = currentUser ?
    <CommentToolbarButton icon={emojiIcon} /> :
    "";

  return (
    <div
      className="navbar-text float-right"
      style={{
        marginRight: 0,
        paddingRight: "10px"
      }}
    >
      {/* placeholder: role icon for admins and moderators--but it's commented out in the original partial? */}
      {/* placeholder: this comment was posted by email */}
      {isUserAuthor && toggleEditButton}
      &nbsp;
      {markSpamButton}
      &nbsp;
      {userCanDeleteComment && deleteButton}
      &nbsp;
      {emojiButton}
    </div>
  );
}

CommentToolbar.propTypes = {
  authorId: PropTypes.number.isRequired,
  currentUser: PropTypes.object,
  deleteButton: PropTypes.element.isRequired,
  nodeAuthorId: PropTypes.number.isRequired,
  toggleEditButton: PropTypes.element.isRequired
};

export default CommentToolbar;
