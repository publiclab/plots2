$(document).ready(function(){
    $('#image_revision').change(function(){
        console.log("inside sample");
        console.log($(this).val());
        $('#main_image').val($('#image_revision option:selected').attr("id"));
        $('#leadImage').attr("src",$('#image_revision option:selected').val());
    });
});