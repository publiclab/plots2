function toggle_sidebar() { 
  if ($('#sidebar').hasClass('d-sm-none')) { 
    $('#sidebar').removeClass('d-sm-none') 
                 .removeClass('d-xs-none') 
  } else { 
    $('#sidebar').addClass('d-sm-none') 
                 .addClass('d-xs-none') 
  } 
}

