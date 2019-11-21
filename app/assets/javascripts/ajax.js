function sendFormSubmissionAjax(dataObj, selector) {
  $.ajax({
    url: $(selector).attr('action'), // grab the URL from the form itself
    data: dataObj,
    success: (event, success) => {
      $(selector).trigger('ajax:success', event);
    }
  });
}