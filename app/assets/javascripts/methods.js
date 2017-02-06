jQuery(document).ready(function($) {

  $('.topic-search').submit(function(e) {
    e.preventDefault();
    window.location = "/methods/" + $('.topic-search input').val();
  });

});
