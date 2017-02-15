//= require wikis/buildSectionForm.js
function processSections(sections, selector, node_id) {
  sections.forEach(function(markdown) {
    processSection(markdown, selector, node_id);
  });
}

// selector is like "#content" -- the container to append the new content to
function processSection(markdown, selector, node_id) {
  var html,
      randomNum   = parseInt(Math.random() * 10000),
      uniqueId    = "section-form-" + randomNum;

  markdown = preProcessMarkdown(markdown);
  html = replaceWithMarkdown(markdown);

  $(selector).append(html);
  var el = $(selector + ' > *:last');

  var formHtml = buildSectionForm(uniqueId, markdown);

  // filter? Only p,h1-5,ul?
  var isMarkdown = markdown.match(/</) === null; // has tags
      isMarkdown = isMarkdown && markdown.match(/\*\*\*\*/) === null; // no horizontal rules

  if (isMarkdown) {
    el.after(formHtml);
    var form = $('#' + uniqueId);
    insertEditLink(uniqueId, el, form);
    form.find('.cancel').click(function inlineEditCancelClick(e) {
      e.preventDefault();
      $(form).hide();
    });
    form.find('button').click(submitSectionForm);
  }

  var message = $('#' + uniqueId + ' .section-message');

  function onComplete(response) {
    if (response === 'true' || response === true) {
      message.html('<i class="fa fa-check" style="color:green;"></i>');
      markdown = $('#' + uniqueId + ' textarea').val();
      form.hide();
      $('#' + uniqueId + ' textarea').val('');
      // replace the section but reset our html and markdown
      html = replaceWithMarkdown(markdown);
      el.replaceWith(replaceWithMarkdown(markdown));
      postProcessContent(el); // add #hashtag and @callout links, extra CSS and deep links
    } else {
      message.html('There was an error -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
    }
  }

  function onFail(response) {
    var message = $('#' + uniqueId + ' .prompt-message');
    message.html('There was an error -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
  }

  function submitSectionForm(e) {
    e.preventDefault();
    message.html('<i class="fa fa-spinner fa-spin" style="color:#ccc;"></i>');
    $.post("/wiki/replace/" + node_id, {
      before: markdown,
      after: form.find('textarea').val()
    })
   .done(onComplete)
   .error(onFail)
   .fail(onFail); // these don't work?
  }
}

function insertEditLink(uniqueId, el, form) {
  var editLink = "";
  editLink += "<a class='inline-edit-link inline-edit-link-" + uniqueId + "'><i class='fa fa-pencil'></i></a>";
  el.append(editLink);
  // drop priority:
  setTimeout(function() {
    $('.inline-edit-link-' + uniqueId).click(function inlineEditLinkClick(e) {
      $(form).show();
console.log('click', $(form), $(form).is(':visible'));
      e.preventDefault();
    });
  },0);
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
