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
  postProcessWiki($('#content'));
}

function postProcessWiki() {

  /* setup bootstrap behaviors */
  $("[rel=tooltip]").tooltip()
  $("[rel=popover]").popover({container: 'body'})
  $('table').addClass('table')

  

  /* add "link" icon to headers */
  $("#content h1, #content h2, #content h3, #content h4").append(function(i,html) {
    return " <small><a href='#" + this.innerHTML.replace(/ /g,'+') + "'><i class='icon fa fa-link'></i></a></small>";
  });

}

function addCallouts(html) {
  var pattern = /(^|\s)@([A-z\_]+)\b/g;
  return html.replace(pattern, function replaceCallouts(m) {
    return '<a href="/profile/' + $2 + '">@' + $2 + '</a>';
  });
}

function addHashtags(html) {
  var pattern = /(^|\s)#([A-z\-]+)\b/g;
  return html.replace(pattern, function replaceCallouts(m) {
    return '<a href="/tag/' + $2 + '">#' + $2 + '</a>';
  });
}
