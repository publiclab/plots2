function alert_clear() { alert_set("hidden",""); }
function alert_notice(msg) { alert_set("alert alert-success", msg); }
function alert_error(msg) { alert_set("alert alert-error", msg); }
function alert_warning(msg) { alert_set("alert alert", msg); }

/*
aclass = "error", "warning", or "notice"
*/
function alert_set(aclass, msg, scroll) {
  // Adds an alert DIV using the alert class aclass and content from msg.
  var new_alert = $(document.createElement("DIV"));
  new_alert.addClass('alert alert-'+aclass);
  new_alert.append('<a class="close" data-dismiss="alert">×</a>');
  if (aclass == "alert alert") {
    new_alert.append('<i class="icon-exclamation-sign"></i> ');
  }
  new_alert.append(msg);
  $('#alert-placeholder').append(new_alert);

  if (scroll) {
    // Scroll page to the alerts
    location.href = '#'; // some kind of Chrome bug fix
    location.href = '#alert-placeholder';
  }
}
