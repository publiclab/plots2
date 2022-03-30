/* eslint-disable complexity */
import { makeDeepCopy } from "./helpers";

const reducer = (state, action) => {
  switch(action.type) {
    // COMMENT actions
    case "CREATE COMMENT":
      return {
        ...state,
        comments: [
          ...state.comments, 
          action.newComment
        ]
      };
    case "UPDATE COMMENT":
      for (let i = 0; i < state.comments.length; i++) {
        // find the comment in state
        if (state.comments[i].commentId === action.newComment.commentId) {
          let newComment = makeDeepCopy(state.comments[i]);
          newComment.htmlCommentText = action.newComment.htmlCommentText; // update comment text
          newComment.rawCommentText = action.newComment.rawCommentText;
          return {
            ...state,
            comments: Object.assign(
              [],
              state.comments,
              { [i]: newComment }
            )
          }; // keep the rest of state.comments, but replace comment at index i with newComment
        }
      }
      break;
    case "DELETE COMMENT":
      for (let i = 0; i < state.comments.length; i++) {
        // find the comment in state by ID
        if (state.comments[i].commentId === action.commentId) {
          return {
            ...state,
            comments: state.comments.filter(comment => action.commentId !== comment.commentId)
          };
        }
      }
      break;

    // COMMENT FORM VISIBILITY actions (eg. handles when a reply form is visible or not)
    case "TOGGLE COMMENT FORM VISIBILITY": // shows/hides reply & edit comment forms when user clicks the toggle button
      return {
        ...state,
        commentFormsVisibility: {
          ...state.commentFormsVisibility,
          [action.commentFormId]: !state.commentFormsVisibility[action.commentFormId]
        }
      };
    case "CREATE NEW COMMENT FORM VISIBILITY":
    case "HIDE COMMENT FORM":
      return {
        ...state,
        commentFormsVisibility: {
          ...state.commentFormsVisibility,
          [action.commentFormId]: false
        }
      }

    // TEXTAREA VALUE actions (eg. updates the values that are displayed in comment form <textarea>s)
    case "CREATE NEW TEXTAREA VALUE":
    case "UPDATE TEXTAREA VALUE":
      return {
        ...state,
        textAreaValues: {
          ...state.textAreaValues,
          [action.commentFormId]: action.newValue
        }
      };

    default:
      throw new Error(); // default should never be called
  }
}

export {
  reducer
}