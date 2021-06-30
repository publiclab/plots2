/* eslint-disable complexity */
import React from "react";

// for making initial textAreaValues state in CommentsContainer.js
// edit comment forms need to be populated with the existing rawCommentText, so user can edit them
const getEditTextAreaValues = (commentsArray) => {
  let editTextValues = {};

  for (let i = 0; i < commentsArray.length; i++) {
    const rawText = commentsArray[i].rawCommentText;
    editTextValues["edit-" + commentsArray[i].commentId] = rawText
  }
  return editTextValues;
};

const getInitialCommentFormsVisibility = (commentsArray) => {
  let commentFormVisibility = {};

  for (let i = 0; i < commentsArray.length; i++) {
    if (!commentsArray[i].replyTo) {
      const replyFormId = "reply-" + commentsArray[i].commentId;
      commentFormVisibility[replyFormId] = false;
    }
    const editFormID = "edit-" + commentsArray[i].commentId;
    commentFormVisibility[editFormID] = false;
  }

  return commentFormVisibility;
};

// for making deep copies of nested arrays and objects
const makeDeepCopy = (input) => {
  let output, value, key;

  if (typeof input !== "object" || input === null || React.isValidElement) {
    return input;
  }

  // outputs either an array or an object, depending on input
  output = Array.isArray(input) ? [] : {};

  for (key in input) {
    if (Object.prototype.hasOwnProperty.call(input, key)) {
      value = input[key];
      // recursive deep copy for nested objects
      output[key] = makeDeepCopy(value);
    }
  }

  return output;
};

export { 
  getEditTextAreaValues,
  getInitialCommentFormsVisibility, 
  makeDeepCopy 
};
