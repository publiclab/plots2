$(document).ready(function() {
  $('input[type="text"], textarea, input[type="password"], .wk-wysiwyg, .wk-prompt').css('cursor','text');
  $(window).on('keypress', function(e) {
    if (e.target.style.cursor !== 'text') {
      if (e.which === 47) {
        $("#searchform_input").focus();
        e.preventDefault();
      }
    }
  });
});
