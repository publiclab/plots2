function alert_clear() { alert_set("hidden",""); }

function alert_notice(msg, options) { alert_set("success", msg, options); }

function alert_error(msg, options) { alert_set("error", msg, options); }

function alert_warning(msg, options) { alert_set("warning", msg, options); }

/* aclass = "error", "warning", or "success" */
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

/* iOS fix for dropdowns in menubar: 
 * https://github.com/publiclab/plots2/issues/17
 */
$('.dropdown-toggle').click(function(e) {
  e.preventDefault();
  setTimeout($.proxy(function() {
    if ('ontouchstart' in document.documentElement) {
      $(this).siblings('.dropdown-backdrop').off().remove();
    }
  }, this), 0);
});

$("[rel=tooltip]").tooltip()
$("[rel=popover]").popover()
$('table').addClass('table')
$('iframe').css('border','none')
$("#content h1, #content h2, #content h3, #content h4").append(function(i,html) {return " <small><a href='#"+this.innerHTML.replace(/ /g,'+')+"'><i class='icon icon-link'></i></a></small>"})
login = function() {
  $('#login-dropdown').toggle()
  $('#login-username-input').focus()
}

/* there may or may not actually be a carousel to activate */
$('#sidebar-carousel').carousel({
  interval: 6000
})

/* google analytics */
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-180781-33']);
_gaq.push(['_setDomainName', 'publiclab.org']);
_gaq.push(['_setAllowLinker', true]);
_gaq.push(['_trackPageview']);

jQuery(document).ready(function($) {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  //ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  ga.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'stats.g.doubleclick.net/dc.js';

  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
}

/* facebook buttons ugh */
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk')););
