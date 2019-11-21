// Takes in a data object that contains the info to be submitted in the form property: dataString
//   and the selector for a form on the page
// Allows data to be submitted from anywhere on the page using Javascript without using the form itself
function sendFormSubmissionAjax(dataObj, selector) {
  $.ajax({
    url: $(selector).attr('action'), // grab the URL from the form
    data: dataObj,
    success: (event, success) => {
      $(selector).trigger('ajax:success', event);
    }
  });
}