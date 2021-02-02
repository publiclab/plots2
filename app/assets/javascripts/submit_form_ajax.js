// Takes in a data object that contains the info to be submitted in the form property: dataString
//   and the url to submit to the controller
// Allows data to be submitted from anywhere on the page using Javascript without using the form itself
function sendFormSubmissionAjax(dataObj, submitTo, responseEl = "", callback) {
  let url = '';
  if(submitTo.slice(0,1) === "/") {
    url = submitTo;
  } else {
    url = $(submitTo).attr('action');
  }
  $.ajax({
    url: url,
    data: dataObj,
    success: (event, success) => {
      if (responseEl !== "") {
        $(responseEl).trigger('ajax:success', event);
      }
      if (callback) callback(event);
    }
  });
}
