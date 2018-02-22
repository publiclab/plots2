function toggle_sidebar() { 
  if ($('#sidebar').hasClass('hidden-sm')) { 
    $('#sidebar').removeClass('hidden-sm') 
                 .removeClass('hidden-xs') 
  } else { 
    $('#sidebar').addClass('hidden-sm') 
                 .addClass('hidden-xs') 
  } 
}
 