/* Leaflet images directory setup */
L.Icon.Default.imagePath = '/assets/leaflet/dist/images/';

/* alert behaviors */
function alert_clear() {
  alert_set("hidden",""); 
}
function alert_notice(msg, options) {
  alert_set("success", msg, options);
}
function alert_error(msg, options) {
  alert_set("error", msg, options);
}
function alert_warning(msg, options) {
  alert_set("warning", msg, options);
}

/* aclass = "error", "warning", or "success" */
function alert_set(aclass, msg, options) {
  // Adds an alert DIV using the alert class aclass and content from msg.
  if (typeof(options)==='undefined') options = {};

  var new_alert = $(document.createElement("DIV"));
  new_alert.addClass('alert alert-'+aclass);
  new_alert.append('<a class="close" data-dismiss="alert">×</a>');
  if (aclass == "warning") {
    new_alert.append('<i class="fa fa-exclamation-sign"></i> ');
  }
  new_alert.append(msg);
  $('#alert-placeholder').append(new_alert);

  if ('scroll' in options && options['scroll']) {
    // Scroll page to the alerts
    location.href = '#'; // some kind of Chrome bug fix
    location.href = '#alert-placeholder';
  }
}

/* window scroll trick for header */
function adjust_anchor_for_banner(offset) {
  offset = offset || 50; // how much to scroll to account for the banner
  var scroll_pos = $(document).scrollTop()
  if (scroll_pos > offset) {
    $(document).scrollTop( scroll_pos - offset );
  }
}
$(window).load(function() { adjust_anchor_for_banner(); })
$(window).on('hashchange', adjust_anchor_for_banner)

/* google analytics */
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-180781-33']);
_gaq.push(['_setDomainName', 'publiclab.org']);
_gaq.push(['_setAllowLinker', true]);
_gaq.push(['_trackPageview']);

jQuery(document).ready(function($) {

  // Google Analytics
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  //ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  ga.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'stats.g.doubleclick.net/dc.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);

  /* facebook buttons ugh */
  (function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));
  
  login = function() {
    $('#login-dropdown').toggle()
    $('#login-username-input').focus()
  }

  // Foldaway code:
  $('p.foldaway-link').click(function() {
    var title = $(this).attr('data-title');
    $('div[data-title="'+title+'"]').animate({height:'toggle'},'slow')
  })

});

function print_linkless() {
  //$('a, a:after').addClass('linkless')
  $('.popover').hide();
  $('body').append('<style> a, a:after { content: normal !important; } </style>');
  window.print();
}

function getUrlParameter(sParam) {
  var sPageURL = window.location.search.substring(1);
  var sURLVariables = sPageURL.split('&');
  for (var i = 0; i < sURLVariables.length; i++) 
  {
      var sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] == sParam) 
      {
          return sParameterName[1];
      }
  }
} 
