  /**
    This functionality operates on the header search form that is part of the primary layout.  It operates the submission of the search form to the general search page.  Any site-wide scripting that should affect the header searches should go here.
  **/
  jQuery(document).ready(function() {
    //Set up the _header search form submission
    $('#searchform').submit(function(e){ 
      e.preventDefault()
      window.location = '/search/'+$('#searchform_input').val()
    });

  });
