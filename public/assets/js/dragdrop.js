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
})
$('#side-dropzone').bind('drop',function(e) {
  e.preventDefault();
})

$('#dropzone').fileupload({
  url: "/images",
  paramName: "image[photo]",
  dropZone: $('#dropzone'),
  dataType: 'json',
  formData: {'uid':$D.uid},
  start: function(e) {
    $('#progress').show()
    $('#imagebar .uploading').show()
    $('#imagebar .prompt').hide()
    $('#dropzone').removeClass('hover');
  },
  done: function (e, data) {
    $('#progress').hide()
    $('#imagebar .uploading').hide()
    $('#imagebar .prompt').show()
    var is_image = false
    if (data.result['filename'].substr(-3,3) == "jpg") is_image = true
    if (data.result['filename'].substr(-4,4) == "jpeg") is_image = true
    if (data.result['filename'].substr(-3,3) == "png") is_image = true
    if (data.result['filename'].substr(-3,3) == "gif") is_image = true
    if (data.result['filename'].substr(-3,3) == "JPG") is_image = true
    if (data.result['filename'].substr(-4,4) == "JPEG") is_image = true
    if (data.result['filename'].substr(-3,3) == "PNG") is_image = true
    if (data.result['filename'].substr(-3,3) == "GIF") is_image = true
    if (is_image) {
      $E.wrap('![',']('+data.result.url.split('?')[0]+')', {'newline': true, 'fallback': data.result['filename']}) // on its own line; see /app/assets/js/editor.js
    } else {
      $E.wrap('<a href="'+data.result.url.split('?')[0]+'"><i class="icon icon-file"></i> ','</a>', {'newline': true, 'fallback': data.result['filename']}) // on its own line; see /app/assets/js/editor.js
    }
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
  start: function(e) {
    $('.side-dropzone').css('border-color','#ccc')
    $('.side-dropzone').css('background','none')
    $('#side-progress').show()
    $('#side-dropzone').removeClass('hover');
    $('.side-uploading').show()
  },
  done: function (e, data) {
    $('#side-progress').hide()
    $('#side-dropzone').show()
    $('.side-uploading').hide()
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

