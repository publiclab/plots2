$(function() {
  // attach AJAX eventHandlers to comment forms for form submission
  // EXCEPT for edit comment forms (those don't use AJAX form submission)
  $('.comment-form').each(function() {
    if(!$(this).hasClass('bound-success') && !$(this).hasClass('edit-comment-form')) {
      $(this).addClass('bound-success').on('ajax:success', function(e, data, status, xhr){
        $(this).find('.text-input').prop('disabled',false);
        $(this).find('.text-input').val('');
        $('#comments-container').append(xhr.responseText);
        $(this).find(".btn-primary").button('reset');
        $(this).find('.comment-preview').hide();
        $(this).find('.text-input').show();
        $(this).find('.preview-btn').button('toggle');
      });
    }

    if(!$(this).hasClass('bound-beforeSend') && !$(this).hasClass('edit-comment-form')) {
      $(this).addClass('bound-beforeSend').on('ajax:beforeSend', function(event){
        $(this).find(".text-input").prop('disabled',true)
        $(this).find('.text-input').val('');
        $(this).find(".btn-primary").button('loading',true);
      });
    }

    if(!$(this).hasClass('bound-error') && !$(this).hasClass('edit-comment-form')) {
      $(this).addClass('bound-error').on('ajax:error', function(e,response){
        notyNotification('mint', 3000, 'error', 'topRight', 'Some error occured while adding comment');
        $(this).find('.text-input').prop('disabled',false);
        $(this).find('.control-group').addClass('has-error')
        $(this).find('.control-group .help-block ').remove()
        $(this).find('.text-input').val('');
        $(this).find('.control-group').append('<span class="help-block ">Error: there was a problem.</span>')
      });
    }

    if(!$(this).hasClass('bound-keypress') && !$(this).hasClass('edit-comment-form')) {
      $(this).addClass('bound-keypress');

      $(this).find('.text-input').val('');
      $(this).on('keypress', function (e) {
        var isPostCommentShortcut = (e.ctrlKey && e.keyCode === 10) || (e.metaKey && e.keyCode === 13);

        if (isPostCommentShortcut) {
          $(this).find(".btn-primary").click();
        }
      });
    }

  });
});

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

// JS API for submitting comments
function addComment(comment, submitTo, parentID = 0) {
  submitTo = submitTo || '.comment-form'; // class instead of id because of the bound function on line 3
  let data = { body: comment };
  if (parentID)  {
    data.reply_to = parentID;
  }
  sendFormSubmissionAjax(data, submitTo);
}

function changeNotificationIcon(target, messageId, buttonId){
  const closestControlGroup = $(target).closest(".control-group")
    closestControlGroup.siblings(messageId).toggle();
    closestControlGroup.find(buttonId).toggleClass("fa-bell-o fa-bell");
}
