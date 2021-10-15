import React from "react";
import PropTypes from "prop-types";

import { UserContext } from "./user-context";
import { StaticPropsContext } from "./static-props-context";
import { getEditTextAreaValues, getInitialCommentFormsVisibility } from "./helpers";

import CommentsContainer from "./CommentsContainer";

const App = ({
  // ES6 destructure the props
  // so we can simply refer to initialComments instead of this.props.initialComments
  currentUser,
  elementText,
  node,
  node: {
    nodeId
  },
  initialComments
}) => {
  // process the initialComments object and create initial state that is passed down to CommentsContainer.js to make React Hooks

  // this is an object containing boolean values like: { "reply-33": false, "edit-1": true }
  // this is used as the initial state showing whether or not an edit or reply comment form is shown or hidden
  // false means the comment form is closed, true means open
  const initialCommentFormsVisibility = getInitialCommentFormsVisibility(initialComments);

  // this is used as initial state for the content of <textarea>s inside comment forms
  // main and reply comment forms are an empty string
  // edit forms must contain the raw comment text to be edited
  // this is an object that holds the contents of multiple text forms:
  //   eg. { main: "foo", reply-123: "bar" }
  const initialTextAreaValues = { 
    "main": "", 
    ...getEditTextAreaValues(initialComments) 
  };

  // React Context ensures that all components below this one can access certain props, without having to pass down component to component
  // currentUser is passed down, as well as static props that do not change (like header text)
  return (
    <UserContext.Provider value={currentUser}>
      <StaticPropsContext.Provider value={{ node, elementText }}>
        <CommentsContainer 
          initialCommentFormsVisibility={initialCommentFormsVisibility}
          initialComments={initialComments} 
          initialTextAreaValues={initialTextAreaValues}
          nodeId={nodeId}
        />
      </StaticPropsContext.Provider>
    </UserContext.Provider>
  );
}

App.propTypes = {
  currentUser: PropTypes.shape({
    canModerate: PropTypes.bool,
    id: PropTypes.number,
    role: PropTypes.string,
    status: PropTypes.number
  }),
  elementText: PropTypes.exact({
    commentFormPlaceholder: PropTypes.string.isRequired,
    commentsHeaderText: PropTypes.string.isRequired,
    commentPreviewText: PropTypes.string.isRequired,
    commentPublishText: PropTypes.string.isRequired,
    userCommentedText: PropTypes.string.isRequired
  }).isRequired,
  initialComments: PropTypes.arrayOf(
    PropTypes.shape({
      authorId: PropTypes.number.isRequired,
      authorPicFilename: PropTypes.string,
      authorPicUrl: PropTypes.string,
      authorUsername: PropTypes.string.isRequired,
      commentId: PropTypes.number.isRequired,
      commentName: PropTypes.string,
      createdAt: PropTypes.string.isRequired,
      htmlCommentText: PropTypes.string.isRequired,
      rawCommentText: PropTypes.string.isRequired,
      replies: PropTypes.array,
      replyTo: PropTypes.number,
      timeCreatedString: PropTypes.string.isRequired
    })
  ).isRequired,
  node: PropTypes.exact({
    nodeId: PropTypes.number.isRequired,
    nodeAuthorId: PropTypes.number.isRequired
  }).isRequired
};

export default App;
