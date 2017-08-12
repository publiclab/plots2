//= require inline-markdown-editor/dist/inlineMarkdownEditor.js
var wiki_title;
function setupWiki(node_id, title, raw, logged_in, current_user) {
  // insert inline forms
  if (raw && logged_in) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], {
      submitUrl: '/wiki/replace/' + node_id
    }));
    wiki_title = title;
    inlineMarkdownEditor({
      replaceUrl: '/wiki/replace/' + node_id,
      selector: '#content-raw-markdown',
      wysiwyg: true,
      preProcessor: preProcessMarkdown,
      postProcessor: postProcessContent,
      extraButtons: {
        "fa-question": questionForm,
        "fa-comment": setupCommentFunction
      },
      editorOptions: {
        history: {
          prefix: "inline-"
        }
      }
    });
    $('#content').hide();
  } else {
    $('#content').html(shortCodePrompt($('#content')[0], {
      submitUrl: '/wiki/replace/' + node_id
    }));
    postProcessContent();
    addDeepLinks($('#content'));
  }

  function questionForm(qbutton, uniqueId) {
    wiki_title = wiki_title.replace(/ /g, "-");
    qbutton.attr('href', '/questions/new?tags=response:' + node_id + ', question%3A' + wiki_title + ', ' + wiki_title + '-' + uniqueId + ', a-wiki-question&template=question&redirect=question').attr('target', '_blank');
  }

  function setupCommentFunction(cbutton, uniqueId){
    var inline_comment_form = buildSectionCommentForm(uniqueId, wiki_title, current_user);
    cbutton.parent().parent().after(inline_comment_form);  
    cbutton.click(function(){
      $('#inline-comment-'+uniqueId).toggle();
    });
  }
}

// add #hashtag and @callout links, extra CSS and deep links
function postProcessContent(element) {
  if (element) addDeepLinks(element);
  element = element || $('body');
  /* setup bootstrap behaviors */
  element.find("[rel=tooltip]").tooltip();
  element.find("[rel=popover]").popover({
    container: 'body',
    trigger: 'focus click'
  });
  element.find('table').addClass('table');
}

/* add "link" icon to headers for example.com#Hash deep links */
function addDeepLinks(element) {
  element.find("h1,h2,h3,h4").append(function(i, html) {
    return " <small><a id='" + this.innerHTML.replace(/ /g, '+') + "' href='#" + this.innerHTML.replace(/ /g, '+') + "'><i class='icon fa fa-link'></i></a></small>";
  });
}

function preProcessMarkdown(markdown) {
  // to preserve blockquote markdown, as in "> a blockquote"
  markdown = markdown.replace('&gt;', '>');
  markdown = reformBadHeaders(markdown);
  return markdown;
}

// insert space between "##Header" => "## Header" to deal with improper markdown header usage
function reformBadHeaders(markdown) {
  return markdown.replace(/($#+|##+)(\w)/g, function(m, p1, p2) {
    return p1 + ' ' + p2;
  })
}
