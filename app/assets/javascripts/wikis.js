//= require wikis/processSections.js
//= require wikis/replaceWithMarkdown.js

/*
* [edit]
* respond to ajax WITHOUT flash[:notice]
* respond with "failed" if replacement doesn't work
* repspond with "ambiguous" if two replacements possible
* pre-screen for ambiguity
* npm?
*/

function setupWiki(node_id, raw) {
  // insert inline forms
  if (raw) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], { submitUrl: '/wiki/replace/' + node_id }));
    $('#content').html('');
    // split by double-newline:
    var sections = $('#content-raw-markdown').html().split('\n\n');
    processSections(sections, '#content', node_id);
  } else {
    $('#content').html(shortCodePrompt($('#content')[0], { submitUrl: '/wiki/replace/' + node_id }));
  }
  postProcessContent($('#content'));
}

// add #hashtag and @callout links, extra CSS and deep links
function postProcessContent(element) {

  /* setup bootstrap behaviors */
  element.find("[rel=tooltip]").tooltip()
  element.find("[rel=popover]").popover({container: 'body'})
  element.find('table').addClass('table')

  var html = element.html();
  html = addCallouts(html);
  html = addHashtags(html);
  element.html(html);

  addDeepLinks(element);
}

/* add "link" icon to headers for example.com#Hash deep links */
function addDeepLinks(element) {
  element.find("h1,h2,h3,h4").append(function(i,html) {
    return " <small><a href='#" + this.innerHTML.replace(/ /g,'+') + "'><i class='icon fa fa-link'></i></a></small>";
  });
}

function addCallouts(html) {
  var pattern = /(^|\s)@([A-z\_]+)\b/g;
  return html.replace(pattern, function replaceCallouts(m, p1, p2) {
    return p1 + '<a href="/profile/' + p2 + '">@' + p2 + '</a>';
  });
}

function addHashtags(html) {
  var pattern = /(^|\s)#([A-z\-]+)\b/g;
  return html.replace(pattern, function replaceHashtags(m, p1, p2) {
    return p1 + '<a href="/tag/' + p2 + '">#' + p2 + '</a>';
  });
}
