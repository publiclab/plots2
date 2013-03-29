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
  formData: {'uid':uid},
  done: function (e, data) {
    $('#dropzone').hide()
    $('#progress').hide()
    $('#leadImage')[0].src = data.result.url
    $('#leadImage').show()

    // here, get the data.result.id and append it to the post form as the lead image

    // do separate drag & drop for inline images

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

