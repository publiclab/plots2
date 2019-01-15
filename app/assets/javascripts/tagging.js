function addTag(tagname, selector) {

  selector = selector || '#tagform';
  if (tagname.slice(0,5).toLowerCase() === "place") {
    place = tagname.split(":")[1];
    place.replace("-", " ");
    geo = geocodeStringAndPan(place);
  }
  else {
    var el = $(selector);

    el.find('.tag-input').val(tagname);

    el.submit();
  }

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
      $('#tags ul:first').append("<li><span id='tag_"+tag_id+"' class='label label-primary'> \
        <a href='/tag/"+tag_name+"'>"+tag_name+"</a> <a class='tag-delete' \
        data-remote='true' href='"+deletion_path+"/"+tag_id+"' data-tag-id='"+tag_id+"' \
        data-method='delete'>x</a></span></li> ")
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

function geocodeStringAndPan(string, onComplete) {
  var url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + string.split(" ").join("+");
  var Blurred = $.ajax({
      async: false,
      url: url,
      complete: function(data) {
        geometry = data.responseJSON.results[0].geometry.location;
        lat = geometry.lat;
        lng = geometry.lng;
        
        var geo = [lat, lng];

        if (geo.length > 0) {
          var r = confirm("This looks like a location. Is this full description of the location accurate?");
          console.log(geo[0]);
          console.log(geo[1]);
          if(r) { 
            addTag("lat:" + geo[0].toString() + ",lng:" + geo[1].toString()+",place:"+string);
          }    
        }
      },
  });
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
