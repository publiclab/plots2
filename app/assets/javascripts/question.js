jQuery(document).ready(function(){

  var check_matched = false;
  var stripped_url = document.location.toString().split("#");

  if (stripped_url.length > 1) {
    var anchor_value = stripped_url[1];
    if (anchor_value.match('answer-0-comment')) {
      check_matched = true;
    }
  }

  if (check_matched) {
    $('.answer-0-comments').show();
  } else {
    $('.answer-0-comments').slice(-3).show();
    if (comments_length > 3) {
      $('#answer-0-comment').prepend('<p id="answer-0-expand" style="color: #006dcc;">View ' + comment_select(0).length + ' previous comments</p>');
      $("#answer-0-expand").on('click', function() {
        expand_comments(0);
      });
    }
  }

  $('#answer-0-comment-form').bind('ajax:send', function(e) {
    $('#answer-0-comment-form #loading-spinner').removeClass('hidden');
    $('#answer-0-comment-form #reply-comment').addClass('hidden');
    $('#answer-0-comment-form #submit-comment-button').addClass('disabled');
    $('#answer-0-comment-form #submit-comment').text('Submitting');
  });

  $('#answer-0-comment-form').bind('ajax:success', function(e, data, status, response) {
    $('#answer-0-comment-form #loading-spinner').addClass('hidden');
    $('#answer-0-comment-form #reply-comment').removeClass('hidden');
    $('#answer-0-comment-form #submit-comment').text('Submit');
    $('#answer-0-comment-form #submit-comment-button').removeClass('disabled');
  });

  $('#answer-0-comment-form').bind('ajax:error', function(e, response) {
    $('#answer-0-comment-form #loading-spinner').addClass('hidden');
    $('#answer-0-comment-form #reply-comment').removeClass('hidden');
    $('#answer-0-comment-form #submit-comment').text('Submit');
    $('#answer-0-comment-form #submit-comment-button').removeClass('disabled');
    $('#answer-0-comment-section .help-block').remove()
    $('#answer-0-comment-section .inline').last().append('<span class="help-block" style="color: red;">Error: there was a problem.</span>');
  });

});
