jQuery(document).ready(function($) {

  //$('#content').hide();
  //$('#content-raw-markdown').show();

  // insert inline forms
  /*
  if (raw) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], { submitUrl: '/wiki/replace/' + node_id }));
    $('#content-raw-markdown').html(marked($('#content-raw-markdown').html()));
  } else {
  */
    //$('#content').html(shortCodePrompt($('#content')[0], { submitUrl: '/wiki/replace/' + node_id }));
  //}

  toggleRaw = function() {
    $("#content-raw-markdown").toggle();
    $("#content").toggle();
  }

  postProcessContent($("#content"));

});
