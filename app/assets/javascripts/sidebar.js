function toggle_sidebar() {
  // made changes transition effect
  $('#sidebar').fadeToggle("slow");
  if ($('#sidebar').hasClass('hidden-sm')) {
    $('#sidebar').removeClass('hidden-sm')
                 .removeClass('hidden-xs')
  } else {
    $('#sidebar').addClass('hidden-sm')
                 .addClass('hidden-xs')
  }
}
