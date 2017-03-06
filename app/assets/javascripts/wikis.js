//= require inline-markdown-editor/dist/inlineMarkdownEditor.js
function setupWiki(node_id, raw, logged_in) {
  // insert inline forms
  if (raw && logged_in) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], { submitUrl: '/wiki/replace/' + node_id }));
    inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/' + node_id,
      selector: '#content-raw-markdown',
      wysiwyg: true,
      preProcessor: preProcessMarkdown,
      postProcessor: postProcessContent
    });
    $('#content').hide();
  } else {
    $('#content').html(shortCodePrompt($('#content')[0], { submitUrl: '/wiki/replace/' + node_id }));
    postProcessContent();
    addDeepLinks($('#content'));
  }
}

// add #hashtag and @callout links, extra CSS and deep links
function postProcessContent(element) {
  if (element) addDeepLinks(element);
  element = element || $('body');
  /* setup bootstrap behaviors */
  element.find("[rel=tooltip]").tooltip();
  element.find("[rel=popover]").popover({container: 'body'});

  element.find('table').addClass('table');
}

/* add "link" icon to headers for example.com#Hash deep links */
function addDeepLinks(element) {
  element.find("h1,h2,h3,h4").append(function(i, html) {
    return " <small><a href='#" + this.innerHTML.replace(/ /g,'+') + "'><i class='icon fa fa-link'></i></a></small>";
  });
}

function preProcessMarkdown(markdown) {
  // to preserve blockquote markdown, as in "> a blockquote"
  markdown = markdown.replace('&gt;', '>');
  // insert space between "##Header" => "## Header" to deal with improper markdown header usage
  markdown = markdown.replace(/$(#+)(\w)/, function(m, p1, p2) {
    return p1 + ' ' + p2;
  })
  return markdown;
}
