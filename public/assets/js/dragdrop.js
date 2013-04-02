// Based on the basic plugin from jQuery file upload: 
// https://github.com/blueimp/jQuery-File-Upload/wiki/Basic-plugin

// #dropzone is for inline images for both wiki and research notes, in:
//     /app/views/editor/_editor.html.erb
//     /app/views/wiki/edit.html.erb
// #side-dropzone, is for the main image of research notes, in /app/views/editor/post.html.erb

$('#dropzone').bind('dragover',function(e) {
  e.preventDefault();
  $('#dropzone').addClass('hover');
})
$('#side-dropzone').bind('dragover',function(e) {
  e.preventDefault();
  $('#side-dropzone').addClass('hover');
})
$('#dropzone').bind('dragout',function(e) {
  $('#dropzone').removeClass('hover');
})
$('#side-dropzone').bind('dragout',function(e) {
  $('#side-dropzone').removeClass('hover');
})
$('#dropzone').bind('drop',function(e) {
  e.preventDefault();
  $('#progress').show()
  $('#imagebar .uploading').show()
  $('#imagebar .prompt').hide()
  $('#dropzone').removeClass('hover');
})
$('#side-dropzone').bind('drop',function(e) {
  e.preventDefault();
  $('#side-progress').show()
  $('#side-dropzone').removeClass('hover');
})

$('#dropzone').fileupload({
  url: "/images",
  paramName: "image[photo]",
  dropZone: $('#dropzone'),
  dataType: 'json',
  formData: {'uid':$D.uid},
  done: function (e, data) {
    $('#progress').hide()
    $('#imagebar .uploading').hide()
    $('#imagebar .prompt').show()
    $E.wrap('![',']('+data.result.url.split('?')[0]+')', {'newline': true, 'fallback': data.result.filename}) // on its own line; see /app/assets/js/editor.js
    // here append the image id to the wiki edit form:
    if ($('#node_images').val() && $('#node_images').val().split(',').length > 1) $('#node_images').val([$('#node_images').val(),data.result.id].join(','))
    else $('#node_images').val(data.result.id)

    // eventual handling of multiple files; must add "multiple" to file input and handle on server side:
    //$.each(data.result.files, function (index, file) {
    //    $('<p/>').text(file.name).appendTo(document.body);
    //});
  },
  // see callbacks at https://github.com/blueimp/jQuery-File-Upload/wiki/Options
  fileuploadfail: function(e,data) {
    
  },
  progressall: function (e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    $('#progress .bar').css(
      'width',
      progress + '%'
    );
  }
});

$('#side-dropzone').fileupload({
  url: "/images",
  paramName: "image[photo]",
  dropZone: $('#side-dropzone'),
  dataType: 'json',
  formData: {'uid':$D.uid},
  done: function (e, data) {
    $('#side-progress').hide()
    $('#side-dropzone').show()
    $('#leadImage')[0].src = data.result.url
    $('#leadImage').show()
    // here append the image id to the note as the lead image
    $('#main_image').val(data.result.id)
  },
  // see callbacks at https://github.com/blueimp/jQuery-File-Upload/wiki/Options
  fileuploadfail: function(e,data) {
    
  },
  progressall: function (e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    $('#side-progress .bar').css(
      'width',
      progress + '%'
    );
  }
});

