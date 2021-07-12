jQuery(document).ready(function() {	 
	var duration = 300;

	$(".back-to-top").click(function(event) {
		event.preventDefault();
		jQuery("html, body").animate({scrollTop: 0}, duration);		 
		return false;
	})

	let options = {
		root: null,
		threshold: .75
	}
	
	function scrollToTop(entries, observer){
		let scrollToTopBtn = $(".back-to-top");
		entries.forEach(entry => {
			if (entry.isIntersecting) {
				scrollToTopBtn.fadeOut(300)
			} else {
				scrollToTopBtn.fadeIn(300)
			}
		})
	}

	let observer = new IntersectionObserver(scrollToTop, options);
	observer.observe(document.querySelector("h1"));
	
});
