import React from "react";
import PropTypes from "prop-types";

import CommentToolbarButton from "./CommentToolbarButton";

const CommentToolbar = ({
  authorId,
  currentUser,
  nodeAuthorId
}) => {
  const editIcon = <i className="fa fa-pencil"></i>;
  const editButton = (currentUser && authorId == currentUser.id) ?
    <CommentToolbarButton icon={editIcon} /> :
    "";
  const markSpamIcon = <i className="fa fa-ban"></i>;
  const flagSpamIcon = <i className="fa fa-flag"></i>;
  const markSpamButton = (currentUser && currentUser.canModerate) ?
    <CommentToolbarButton icon={markSpamIcon} /> :
    <CommentToolbarButton icon={flagSpamIcon} />;
  {/* original Rails view's conditionals include logged_in_as['admin', 'moderator'] */}
  {/* don't know if this is completely equivalent to user.canModerate */}
  const deleteIcon = <i className='icon fa fa-trash'></i>;
  const deleteButton = (
    currentUser && authorId == currentUser.id ||
    currentUser && currentUser.canModerate ||
    authorId == nodeAuthorId
  ) ?
    <CommentToolbarButton icon={deleteIcon} /> :
    "";
  const emojiIcon = <i className='far fa-heart'></i>;
  const emojiButton = currentUser ?
    <CommentToolbarButton icon={emojiIcon} /> :
    "";

  return (
    <>
      {editButton}
      &nbsp;
      {markSpamButton}
      &nbsp;
      {deleteButton}
      &nbsp;
      {emojiButton}
    </>
  );
}

CommentToolbar.propTypes = {
  authorId: PropTypes.number,
  nodeAuthorId: PropTypes.number
};

export default CommentToolbar;
