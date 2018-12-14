
  /**
    This functionality operates on the header search form that is part of the primary layout.  It operates the submission of the search form to the general search page.  Any site-wide scripting that should affect the header searches should go here.
  **/
$(function() {
  //Set up the _header search form submission
  $('#searchform').submit(function(e){
    e.preventDefault();
    var encoded_query = encodeURIComponent($('#searchform_input').val());
    window.location = "/search/" + encoded_query;
  });
});

$(function () {
  $('body').on('keydown', '#searchform_input', function (e) {
    if (e.which === 32 && this.value === '') {
      return false;
    }
  });
});