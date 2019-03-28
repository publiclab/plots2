(function() {

  $('.comment-form').each(function() {
    if(!$(this).hasClass('bound-success')) {
      $(this).addClass('bound-success').bind('ajax:success', function(e, data, status, xhr){
        $(this).find('#text-input').prop('disabled',false);
        $(this).find('#text-input').val('');
        $('#comments-container').append(xhr.responseText);
        $('#comment-count')[0].innerHTML = parseInt($('#comment-count')[0].innerHTML, 10)+1;
        $(this).find(".btn-primary").button('reset');
        $(this).find('#preview').hide();
        $(this).find('#text-input').show();
        $(this).find('#preview-btn').button('toggle');
      });
    }

    if(!$(this).hasClass('bound-beforeSend')) {
      $(this).addClass('bound-beforeSend').bind('ajax:beforeSend', function(event){
        $(this).find("#text-input").prop('disabled',true)
        $(this).find(".btn-primary").button('loading',true);
      });
    }

    if(!$(this).hasClass('bound-error')) {
      $(this).addClass('bound-error').bind('ajax:error', function(e,response){
        notyNotification('mint', 3000, 'success', 'topRight', 'Some error occured while adding comment');
        $(this).find('.control-group').addClass('has-error')
        $(this).find('.control-group .help-block ').remove()
        $(this).find('.control-group').append('<span class="help-block ">Error: there was a problem.</span>')
      });
    }

    if(!$(this).hasClass('bound-keypress')) {
      $(this).addClass('bound-keypress');
      $(this).find('#text-input').bind('keypress',function(e){
        if (e.ctrlKey && e.keyCode === 10) {
        $(this).find(".btn-primary").click();
        }
      })
    }
    
  });
}());

function insertTitleSuggestionTemplate() {
  var element = $('#text-input');
  var currentText = $('#text-input').val().trim();
  var template = "\n[propose:title]Propose your title here[/propose]";
  if (currentText.length === 0) { 
    template = "[propose:title]Propose your title here[/propose]";
  }
  var newText = currentText+template;
  element.val(newText);
}
