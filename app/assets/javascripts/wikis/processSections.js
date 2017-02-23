//= require wikis/replaceWithMarkdown.js
//= require wikis/buildSectionForm.js
//= require wikis/insertEditLink.js

function processSections(sections, o) {
  sections.forEach(function(markdown) {
    processSection(markdown, {
      replaceUrl: o.replaceUrl,
      selector: o.selector, 
      postProcessor: o.postProcessor,
      preProcessor: o.preProcessor
    });
  });
}

// selector is like "#content" -- the container to append the new content to
function processSection(markdown, o) {
  var html,
      randomNum   = parseInt(Math.random() * 10000),
      uniqueId    = "section-form-" + randomNum;

  if (o.preProcessor) markdown = o.preProcessor(markdown);
  html = replaceWithMarkdown(markdown);

  $(o.selector).append('<div class="inline-section inline-section-' + uniqueId + '"></div>');
  var el = $(o.selector).find('.inline-section:last');
  el.append(html);

  if (o.postProcessor) o.postProcessor();
  var form = insertFormIfMarkdown(markdown, el, uniqueId);

  var message = $('#' + uniqueId + ' .section-message');

  function insertFormIfMarkdown(markdown, el, uniqueId) {
    // filter? Only p,h1-5,ul?
    var isMarkdown = markdown.match(/</) === null; // has tags
        isMarkdown = isMarkdown && markdown.match(/\*\*\*\*/) === null; // no horizontal rules
 
    if (isMarkdown) {
      var formHtml = buildSectionForm(uniqueId, markdown);
      el.after(formHtml);
      var form = $('#' + uniqueId);
      insertEditLink(uniqueId, el, form, onEdit);

      // we get the rich editor back in the onEdit callback:
      function onEdit(editor) {
        form.find('.cancel').click(function inlineEditCancelClick(e) {
          e.preventDefault();
          form.hide();
        });
        form.find('button.submit').click(function(e) {
          submitSectionForm(e, form, editor)
        });
      }
    }
 
    function submitSectionForm(e, form, editor) {
      e.preventDefault();
      message.html('<i class="fa fa-spinner fa-spin" style="color:#ccc;"></i>');
      if (editor) {
        changes = editor.richTextModule.value(); // rich editor
      } else {
        changes = form.find('textarea').val();
      }
      $.post(o.replaceUrl, {
        before: markdown,
        after: changes
      })
      .done(onComplete)
      .error(onFail)
      .fail(onFail); // these don't work?

      function onComplete(response) {
        if (response === 'true' || response === true) {
          message.html('<i class="fa fa-check" style="color:green;"></i>');
          markdown = changes;
          $('#' + uniqueId + ' textarea').val('');
          form.hide();
          // replace the section but reset our html and markdown
          html = replaceWithMarkdown(markdown);
          el.html(html);
          insertEditLink(uniqueId, el, form);
          if (o.postProcessor) o.postProcessor(el); // add #hashtag and @callout links, extra CSS and deep links
        } else {
          message.html('<b style="color:#a33">There was an error</b> -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
        }
      }
  
      function onFail(response) {
        var message = $('#' + uniqueId + ' .prompt-message');
        message.html('There was an error -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
      }
    }

    return form;
  }
}
