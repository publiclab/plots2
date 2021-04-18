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

  postProcessContent();
  addDeepLinks($('#content'));



  $('#replications').find('a.btn').click(function(e) {
    e.preventDefault();
    $('.activity-comment#i-did-this').find('textarea').val('I did this!');
    $('.activity-comment#i-did-this').show();
    $('.activity-comment#i-did-this').focus();
  });

  $('.activity-comment#i-did-this').find('button.btn-primary').click(function(e) {
    $('.activity-comment#i-did-this').hide();
  });
  $(".datepicker").datepicker({format: 'mm-dd-yyyy'});
  $("#collapse-button").click(function(){
      $(this).remove();
  });
  $(function() {
    $("img").lazyload();
  });
  $("#event-datepicker").hide();
  $("#date-toggle").click(function(){
    $("#event-datepicker").toggle();
  });
  $("#save-event-date").click(function(){
    eventDate= $(".datepicker").datepicker();
    if(eventDate!== null)
    {
      addTag("date:"+eventDate.val());
      $('#mytoast').addClass("show").fadeIn('fast').delay(2000).fadeOut('fast');
      $("#event-datepicker").hide();
      $("#date-toggle").hide();
    }
  });
});
