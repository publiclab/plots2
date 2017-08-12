function addTag(tagname, selector) {

  selector = selector || '#tagform';

  var el = $(selector);

  el.find('.tag-input').val(tagname);

  el.submit();

}

function setupTagDelete(el) {

  el.click(function(e) {
      $(this).css('opacity', 0.5)
    })
    .bind('ajax:success', function(e, tid){
      $('#tag_' + tid).remove();
    });
  return el;

}

function initTagForm(deletion_path, selector) {

  selector = selector || '#tagform';

  var el = $(selector);

  el.bind('ajax:beforeSend', function(){
    el.find(".tag-input").prop('disabled', true)
  });

  el.bind('ajax:success', function(e, response){
    if (typeof response == "string") response = JSON.parse(response)
    $.each(response['saved'], function(i,tag) {
      var tag_name = tag[0];
      var tag_id = tag[1];
      $('#tags p:first').append("<span id='tag_"+tag_id+"' class='label label-primary' style='font-size:13px;'><a href='/tag/"+tag_name+"'>"+tag_name+"</a> <a class='tag-delete' data-remote='true' href='"+deletion_path+"/"+tag_id+"' data-tag-id='"+tag_id+"'>x</a></span> ")
      el.find('.tag-input').val("")
      el.find('.control-group').removeClass('has-error')
      el.find('.control-group .help-block').remove()
      setupTagDelete($('#tag_' + tag_id + ' .tag-delete'));
    })
    if (response['errors'].length > 0) {
      el.find('.control-group').addClass('has-error')
      el.find('.control-group .help-block').remove()
      el.find('.control-group').append('<span class="help-block">' + response['errors'] + '</span>')
    }
    el.find('.tag-input').prop('disabled',false)
  });

  el.bind('ajax:error', function(e, response){
    el.find('.control-group').addClass('has-error')
    el.find('.tag-input').prop('disabled', false)
    el.find('.control-group .help-block').remove();
    el.find('.control-group').append('<span class="help-block">' + response.responseText + '</span>')
  });

  setupTagDelete($('.tag-delete'));

  el.find('.tag-input').typeahead({
    items: 8,
    minLength: 3,
    source: function (query, process) {
      return $.post('/tag/suggested/' + query, {}, function (data) {
        return process(data);
      })
    },
    updater: function(text) { 
      el.find('.tag-input').val(text);
      el.submit();
    }
  });

  return el;

}
