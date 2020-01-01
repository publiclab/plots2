$(document).ready(function(){
  $('#image_revision').change(function(){
    $('#main_image').val($('#image_revision option:selected').attr("id"));
    $('#leadImage').attr("src",$('#image_revision option:selected').val());
  });
});
