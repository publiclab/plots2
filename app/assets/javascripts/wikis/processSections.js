//= require wikis/buildSectionForm.js
//= require wikis/setupSectionForm.js
//= require wikis/insertEditLink.js

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

  $(selector).append('<div class="inline-section"></div>');
  var el = $(selector).find('.inline-section:last');
  el.append(html);

  postProcessContent(el);
  var form = insertFormIfMarkdown(markdown, el, uniqueId);

  var message = $('#' + uniqueId + ' .section-message');

  function onComplete(response) {
    if (response === 'true' || response === true) {
      message.html('<i class="fa fa-check" style="color:green;"></i>');
      markdown = $('#' + uniqueId + ' textarea').val();
      $('#' + uniqueId + ' textarea').val('');
      form.hide();
      // replace the section but reset our html and markdown
      html = replaceWithMarkdown(markdown);
      el.html(html);
      postProcessContent(el); // add #hashtag and @callout links, extra CSS and deep links
// rebuild the form (consider recursing?):
// NOT WORKING
      insertFormIfMarkdown(markdown, el, uniqueId);
    } else {
      message.html('There was an error -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
    }
  }

  function onFail(response) {
    var message = $('#' + uniqueId + ' .prompt-message');
    message.html('There was an error -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
  }

  function insertFormIfMarkdown(markdown, el, uniqueId) {
    // filter? Only p,h1-5,ul?
    var isMarkdown = markdown.match(/</) === null; // has tags
        isMarkdown = isMarkdown && markdown.match(/\*\*\*\*/) === null; // no horizontal rules
 
    if (isMarkdown) {
      var formHtml = buildSectionForm(uniqueId, markdown);
      el.after(formHtml);
      setupSectionForm(uniqueId);
      var form = $('#' + uniqueId);
      insertEditLink(uniqueId, el, form);
      form.find('.cancel').click(function inlineEditCancelClick(e) {
        e.preventDefault();
        form.hide();
      });
      form.find('button.submit').click(submitSectionForm);
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

    return form;
  }
}
