// Based on the basic plugin from jQuery file upload: 
// https://github.com/blueimp/jQuery-File-Upload/wiki/Basic-plugin

$('#dropzone').bind('dragover',function(e) {
  e.preventDefault();
  $('#dropzone').addClass('hover');
})
$('#dropzone').bind('dragout',function(e) {
  $('#dropzone').removeClass('hover');
})
$('#dropzone').bind('drop',function(e) {
  e.preventDefault();
  $('#dropzone').removeClass('hover');
},false)

$('#dropzone').fileupload({
  url: "/images",
  paramName: "image[photo]",
  dropZone: $('#dropzone'),
  dataType: 'json',
  formData: {'uid':$D.uid},
  done: function (e, data) {
    $('#progress').hide()
    if ($D.type == "note") {
      $('#dropzone').hide()
      $('#leadImage')[0].src = data.result.url
      $('#leadImage').show()
      // here append the image id to the note as the lead image
      $('#main_image').val(data.result.id)
    } else { // it's a wiki!
      $E.wrap('![',']('+data.result.url.split('?')[0]+')', {'newline': true, 'fallback': data.result.filename}) // on its own line; see /app/assets/js/editor.js
      // here append the image id to the wiki edit form:
      if ($('#node_images').val().split(',').length > 1) $('#node_images').val([$('#node_images').val(),data.result.id)].join(','))
      else $('#node_images').val(data.result.id)
    }

    // eventual handling of multiple files; must add "multiple" to file input and handle on server side:
    //$.each(data.result.files, function (index, file) {
    //    $('<p/>').text(file.name).appendTo(document.body);
    //});
  },
  // This does not yet work. Check out: https://github.com/blueimp/jQuery-File-Upload/wiki/Options
  progressall: function (e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    $('#progress .bar').css(
      'width',
      progress + '%'
    );
  }
});

