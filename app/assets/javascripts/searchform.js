jQuery(document).ready(function() {
  //Set up the _header search form submission
  $('#searchform').submit(function(e){ 
    e.preventDefault()
    window.location = '/search/'+$('#searchform_input').val()
  });

})
