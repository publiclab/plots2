function alert_clear() { alert_set("hidden",""); }
function alert_notice(msg, options) { alert_set("success", msg, options); }
function alert_error(msg, options) { alert_set("error", msg, options); }
function alert_warning(msg, options) { alert_set("warning", msg, options); }

/*
aclass = "error", "warning", or "success"
*/
function alert_set(aclass, msg, options) {
  // Adds an alert DIV using the alert class aclass and content from msg.
  if (typeof(options)==='undefined') options = {};

  var new_alert = $(document.createElement("DIV"));
  new_alert.addClass('alert alert-'+aclass);
  new_alert.append('<a class="close" data-dismiss="alert">×</a>');
  if (aclass == "warning") {
    new_alert.append('<i class="icon-exclamation-sign"></i> ');
  }
  new_alert.append(msg);
  $('#alert-placeholder').append(new_alert);

  if ('scroll' in options && options['scroll']) {
    // Scroll page to the alerts
    location.href = '#'; // some kind of Chrome bug fix
    location.href = '#alert-placeholder';
  }
}
