module.exports = function processSection(markdown, o) {
  var html,
      randomNum   = parseInt(Math.random() * 10000),
      uniqueId    = "section-form-" + randomNum,
      filteredMarkdown = markdown;

  var originalSectionMarkdown = markdown;
  filteredMarkdown = o.preProcessor(markdown);
  html = o.defaultMarkdown(filteredMarkdown);

  $(o.selector).append('<div class="inline-section inline-section-' + uniqueId + '"></div>');
  var el = $(o.selector).find('.inline-section:last');
  el.append(html);

  if (o.postProcessor) o.postProcessor(el);
  var form = insertFormIfMarkdown(filteredMarkdown, el, uniqueId);

  var message = $('#' + uniqueId + ' .section-message');

  function insertFormIfMarkdown(_markdown, el, uniqueId) {
    if (o.isEditable(_markdown, o.preProcessor(o.originalMarkdown))) {
      var formHtml = o.buildSectionForm(uniqueId, _markdown);
      el.after(formHtml);
      var _form = $('#' + uniqueId);
      o.insertEditLink(uniqueId, el, _form, onEdit, false, o);
      // plan for swappable editors; will need to specify both constructor and onEditorSubmit
      function onEdit() {
        var editor;
        if (o.wysiwyg && $('#' + uniqueId).find('.wk-container').length === 0) {
          // insert rich editor
          var editorOptions = o.editorOptions || {};
          editorOptions.textarea = $('#' + uniqueId + ' textarea')[0];
          editor = new PL.Editor(editorOptions);
        }
        _form.find('.cancel').click(function inlineEditCancelClick(e) {
          e.preventDefault();
          _form.hide();
        });
        _form.find('button.submit').click(function(e) {
          prepareAndSendSectionForm(e, _form, editor, originalSectionMarkdown);
        });
      }
    }

    function prepareAndSendSectionForm(e, __form, _editor, _markdown) {
      message.html('<i class="fa fa-spinner fa-spin" style="color:#ccc;"></i>');
      if (_editor) {
        changes = _editor.richTextModule.value(); // rich editor
      } else {
        changes = __form.find('textarea').val();
      }
      o.submitSectionForm(e, _markdown, changes, o, el, __form);
    }

    // provide overridable default; though we have to explicitly pass in
    // all this stuff so the section forms don't get crossed 
    o.submitSectionForm = o.submitSectionForm || function submitSectionForm(e, before, after, o, _el, __form) {
      e.preventDefault();
      $.post(o.replaceUrl, {
        before: before, // encodeURI(before)
        after: after // encodeURI(after)
      })
      .done(function onComplete(response) {
        // we should need fewer things here:
        o.onComplete(response, after, html, _el, uniqueId, __form, o);
      }).fail(function onFail(response) {
        o.onFail(response, uniqueId);
      }); // these don't work?
    }

    return _form;
  }
}
