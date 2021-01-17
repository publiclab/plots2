// used in editor.js & dragdrop.js
const getEditorParams = (targetDiv) => {
  const closestCommentFormWrapper = targetDiv.closest('div.comment-form-wrapper'); // this returns null if there is no match
  let params = {};
  // there are no .comment-form-wrappers on /wiki/edit or /wiki/new
  // these pages just have a single text-input form.
  if (closestCommentFormWrapper) {
    params['dSelected'] = $(closestCommentFormWrapper);
    // assign the ID of the textarea within the closest comment-form-wrapper
    params['textarea'] = closestCommentFormWrapper.querySelector('textarea').id;
  } else {
    // default to #text-input
    // #text-input ID should be unique, and the only comment form on /wiki/new & /wiki/edit
    params['textarea'] = 'text-input';
  }
  return params;
};