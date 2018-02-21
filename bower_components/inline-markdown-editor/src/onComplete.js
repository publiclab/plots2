module.exports = function onComplete(response, markdown, html, el, uniqueId, form, o) {
  var message = form.find('.section-message');
  if (response === 'true' || response === true) {
    message.html('<i class="fa fa-check" style="color:green;"></i>');
    //markdown = changes;
    $('#' + uniqueId + ' textarea').val('');
    form.hide();
    // replace the section but reset our html and markdown
    html = o.defaultMarkdown(markdown);
    el.html(html);
    o.insertEditLink(uniqueId, el, form, false, false, o);
    if (o.postProcessor) o.postProcessor(el); // add #hashtag and @callout links, extra CSS and deep links
  } else {
    message.html('<b style="color:#a33">There was an error</b> -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
  }
}
