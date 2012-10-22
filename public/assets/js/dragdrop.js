$('#dropzone').bind('dragover',function(e) {
  e.stopPropagation();
  e.preventDefault();
  $('#drop_zone').addClass('hover');
  e.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
})
$('#dropzone').bind('dragout',function(e) {
  $('#dropzone').removeClass('hover');
})
$('#dropzone').bind('drop',function(e) {
  e.stopPropagation();
  e.preventDefault();
})

