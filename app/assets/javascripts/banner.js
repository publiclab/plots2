function adjust_anchor_for_banner() {
	var banner_offset = 50; // how much to scroll to account for the banner
	var scroll_pos = $(document).scrollTop()
	if (scroll_pos > banner_offset) {
	  $(document).scrollTop( scroll_pos - banner_offset );
	}
}

$(document).ready(adjust_anchor_for_banner)
$(window).on('hashchange', adjust_anchor_for_banner)
