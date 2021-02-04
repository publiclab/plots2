// Takes in a data object that contains the info to be submitted in the form property: dataString
//   and the url to submit to the controller
// Allows data to be submitted from anywhere on the page using Javascript without using the form itself
function sendFormSubmissionAjax(dataObj, submitTo, responseEl = "", callback) {
  let url = urlValue(submitTo);
  $.ajax({
    url: url,
    data: dataObj
  })
  .done((event) =>{
    if (!!responseEl) {
      $(responseEl).trigger('ajax:success', event);
    }
    callback && callback(event);
  })
}

function urlValue(submitTo){
  let value = '';
  if(submitTo.slice(0,1) === "/") {
    value = submitTo;
  } else {
    value = $(submitTo).attr('action');
  }
  return value;
}
