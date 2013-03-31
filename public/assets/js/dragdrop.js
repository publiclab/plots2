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
    } else { // it's a wiki!
      $E.wrap('\n\n![',']('+data.result.url+')\n\n')
    }
    // here, get the data.result.id and append it to the post form as the lead image

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

