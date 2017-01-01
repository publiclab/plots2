function comment_select(question_id){
  return $('.answer-' + question_id + '-comments').filter(function(){
    return $(this).css('display') == 'none';
  })
}

function expand_comments(question_id){
  if (comment_select(question_id).length > 0){
    comment_select(question_id).slice(-3).show();
    $('#answer-' + question_id + '-expand').text('View ' + comment_select(question_id).length + ' more comments');
    if (comment_select(question_id).length == 0){
      $('#answer-' + question_id + '-expand').hide();
    }
  }
}