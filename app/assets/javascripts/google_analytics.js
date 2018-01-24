$(document).on("turbolinks:load", function() {
	if (typeof ga == "function"){
		ga("set", "location", event.data.url)
    	ga("send", "pageview")	
	}
});
