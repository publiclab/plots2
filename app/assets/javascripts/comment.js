(function() {
  $('#text-input').bind('keypress',function(e){
    if (e.ctrlKey && e.keyCode === 10) {
    $("#comment-form .btn-primary").click();
    }
  })

  $('#comment-form').bind('ajax:beforeSend', function(event){
    $("#text-input").prop('disabled',true)
    $("#comment-form .btn-primary").button('loading',true);
  });

  $('#comment-form').bind('ajax:success', function(e, data, status, xhr){
    $('#text-input').prop('disabled',false);
    $('#text-input').val('');
    $('#comments-container').append(xhr.responseText);
    $('#comment-count')[0].innerHTML = parseInt($('#comment-count')[0].innerHTML, 10)+1;
    $("#comment-form .btn-primary").button('reset');
    $('#preview').hide();
    $('#text-input').show();
    $('#preview-btn').button('toggle');
  });

  $('#comment-form').bind('ajax:error', function(e,response){
    notyNotification('mint', 3000, 'success', 'topRight', 'Some error occured while adding comment');
    $('#comment-form .control-group').addClass('has-error')
    $('#comment-form .control-group .help-block ').remove()
    $('#comment-form .control-group').append('<span class="help-block ">Error: there was a problem.</span>')
  });
}());

function insertTitleSuggestionTemplate() {
  var element = $('#text-input');
  var currentText = $('#text-input').val().trim();
  var template = "\n[propose:title]Propose your title here[/propose]";
  if(currentText.length === 0)
  template = "[propose:title]Propose your title here[/propose]";
  var newText = currentText+template;
  element.val(newText);
}
