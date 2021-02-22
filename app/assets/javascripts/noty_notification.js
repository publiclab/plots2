function notyNotification(theme, timeout, type, layout, text){
	new Noty({
		theme: theme,
		timeout: timeout,
		type: type,
		layout: layout,
		text: text
	}).show();
}

// More details about themes, layouts and more can be found at : https://ned.im/noty
//= require noty_notification.js
