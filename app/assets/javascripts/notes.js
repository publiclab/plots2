jQuery(document).ready(function($) {

  $('#content').hide();
  $('#content-raw-markdown').show();

  // insert inline forms
  /*
  if (raw) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], { submitUrl: '/wiki/replace/' + node_id }));
    $('#content-raw-markdown').html(marked($('#content-raw-markdown').html()));
  } else {
  */
    $('#content').html(shortCodePrompt($('#content')[0], { submitUrl: '/wiki/replace/' + node_id }));
  //}

  toggleRaw = function() {
    $("#content-raw-markdown").toggle();$("#content").toggle();
  }

  /* setup bootstrap behaviors */
  $("[rel=tooltip]").tooltip()
  $("[rel=popover]").popover({container: 'body'})
  $('table').addClass('table')
  
  $('iframe').css('border','none')
  
  /* add "link" icon to headers */
  $("#content-raw-markdown h1, #content-raw-markdown h2, #content-raw-markdown h3, #content-raw-markdown h4, #content h1, #content h2, #content h3, #content h4").append(function(i,html) {return " <small><a href='#" + this.innerHTML.replace(/ /g,'+') + "'><i class='icon fa fa-link'></i></a></small>"})

});
