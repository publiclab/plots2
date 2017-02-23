//= require wikis/processSections.js

function inlineMarkdownEditor(o) {
  var el = $(o.selector);
  // split by double-newline:
  var sections = el.html().split('\n\n');
  el.html('');
  processSections(sections, {
    replaceUrl: o.replaceUrl,
    selector: o.selector,
    preProcessor: o.preProcessor,
    postProcessor: o.postProcessor
  });
  el.show();
}
