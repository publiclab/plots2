jQuery(document).ready(function() {	 
	

	$(window).scroll(function() {
    if ($(this).scrollTop() >= 50) {        // If page is scrolled more than 50px
        $('.back-to-top').fadeIn(200);    // Fade in the button
    } else {
        $('.back-to-top').fadeOut(200);   // Else fade out the button
    }
});
$('.back-to-top').click(function() {      // When button is clicked
    $('body,html').animate({
        scrollTop : 0                       // Scroll to top of body
    }, 500);
});

	
});
 