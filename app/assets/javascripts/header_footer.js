jQuery(document).ready(function() {	 
	var duration = 300;

	$(".back-to-top").click(function(event) {
		event.preventDefault();
		jQuery("html, body").animate({scrollTop: 0}, duration);		 
		return false;
	})
	
});
 