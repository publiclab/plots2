// Taking the prompt+value retrieved in promptTag() or the links in the drop-down menu and populating the form field before submitting it
// Instead we want to take the tag value and directly submit it with AJAX
// responseEl is the page element that we want the messages being appended to
// callback is an optional function that will be passed and invoked when a request is successful
function addTag(tagname, submitTo, responseEl = "", callback) {
  submitTo = submitTo || '#tagform';
  if (responseEl == "") {
    if(submitTo.slice(0,1) === "/") {
      responseEl = '#tagform';
    } else {
      responseEl = submitTo;
    }
  }
  if (tagname.slice(0,5).toLowerCase() === "place") {
    tagname = tagname.replace(/ /g, '-');
  }
  let data = { name: tagname };
  sendFormSubmissionAjax(data, submitTo, responseEl, callback);
}

function setupTagDelete(el) {
  el.click(function(e) {
      $(this).css('opacity', 0.5)
    })
    .bind('ajax:success', function(e, response){
      if (typeof response == "string") response = JSON.parse(response)
      if (response['status'] == true) { 
        $('#tag_' + response['tid']).remove() 
      } else {
        $('.control-group').addClass('has-error')
        $('.control-group .help-block').remove()
        $('.control-group').append('<span class="help-block">' + response['errors'] + '</span>')
      }
    });
  return el;
}

function initTagForm(deletion_path, selector) {

  selector = selector || '#tagform';
  var el = $(selector);

  el.bind('ajax:beforeSend', function(){
    el.find(".tag-input").prop('disabled', true)
  });

  el.bind('ajax:success', function(e, response) {
    addNewTagsSuccess(response, deletion_path, el);
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
    item: '<li class="dropdown-item"><a class="dropdown-item" href="#" role="option"></a></li>',
    updater: function(text) { 
      el.find('.tag-input').val(text);
      el.submit();
    }
  });

  return el;

}

function addNewTagsSuccess(response, deletion_path, el = "#tagform"){
  if (typeof response == "string") response = JSON.parse(response)
  $.each(response['saved'], function(i, tag) {
    // only display tag if it was added to the note we're currently viewing
    var tagNameCheck = !!tag[0].split(':')[0].match(/^(lat|lon|place)$/)
    if (tagNameCheck) {
      location.reload(true);
    }
    if (tag[2] == getDeletionPathId(deletion_path)) {
      displayNewTag(tag[0], tag[1], deletion_path);
    }
    el.find('.tag-input').val("")
    el.find('.control-group').removeClass('has-error')
    el.find('.control-group .help-block').remove()
  })
  if (response['errors'].length > 0) {
    el.find('.control-group').addClass('has-error')
    el.find('.control-group .help-block').remove()
    el.find('.control-group').append('<span class="help-block">' + response['errors'] + '</span>')
  }
  el.find('.tag-input').prop('disabled',false)
  el.find('.tag-input').focus()
}

function displayNewTag(tag_name, tag_id, deletion_path) {
  $('.tags-list:first').append("<p id='tag_"+tag_id+"' class='badge badge-primary m-0'> \
    <a class='tag-name' style='color:white;' href='/tag/"+tag_name+"'>"+tag_name+"</a> <a class='tag-delete' \
    data-remote='true' href='"+deletion_path+"/"+tag_id+"' data-tag-id='"+tag_id+"' \
    data-method='delete'><i class='fa fa-times-circle fa-white blue pl-1' aria-hidden='true' ></i></a></p> ")
  setupTagDelete($('#tag_' + tag_id + ' .tag-delete'));
}

function getDeletionPathId(deletion_path) {
  return deletion_path.split("/").pop();
}

function promptTag(val) {
  var input;
  switch(val) {

    case "series:":
      input = prompt("Enter a unique tag to link your series together, using dashes; it will be displayed with a message like 'This is part of a series on monitoring-landfills'");
      if (input !== null) addTag(val + input);
      break;

    case "lang:":
      input = prompt("Enter the language code; for example, for Spanish, enter 'es'", 'es');
      if (input !== null) addTag(val + input);
      break;

    case "parent:":
      input = prompt("Enter the end of the URL for another wiki page; for example, for '/wiki/stormwater', enter 'stormwater'");
      if (input !== null) addTag(val + input);
      break;

    case "style:":
      input = prompt("What kind of style? (minimal, fancy, presentation, wide, nobanner)", "minimal");
      if (input !== null) addTag(val + input);
      break;

    case "with:":
      input = prompt("Who would you like to add as a coauthor?", "Username");
      if (input !== null) addTag(val + input);
      break;

    case "comment-template:":
      var input = prompt("Add a template for the comment field to guide responses; enter the name (i.e. 'survey-template' for /wiki/survey-template) of a wiki page to use as the template:", "wiki-template-name");
      if (input !== null) addTag(val + input);
      break;

    default:
      addTag(expr);
      break;

  }
}
