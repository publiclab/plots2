function toggle_sidebar() { 
  if ($('#sidebar').hasClass('d-none')) { 
    $('#sidebar').removeClass('d-none') 
                 .removeClass('d-sm-block') 
                 .removeClass('d-md-none') 
                 .removeClass('d-lg-block') 
  } else { 
    $('#sidebar').addClass('d-none') 
                 .addClass('d-sm-block') 
                 .addClass('d-lg-block') 
                 .addClass('d-md-none') 
  } 
}
 
