inlineMarkdownEditor = function inlineMarkdownEditor(o) {
  o.defaultMarkdown = o.defaultMarkdown || require('./defaultMarkdown.js');
  o.buildSectionForm = o.buildSectionForm || require('./buildSectionForm.js');
  o.insertEditLink = o.insertEditLink || require('./insertEditLink.js');
  o.onComplete = o.onComplete || require('./onComplete.js');
  o.onFail = o.onFail || require('./onFail.js');
  o.isEditable = o.isEditable || require('./isEditable.js');
  o.processSections = require('./processSections.js');
  var el = $(o.selector);
  o.originalMarkdown = el.html();
  o.preProcessor = o.preProcessor || function(m) { return m; }
  // split by double-newline:
  var sections = o.originalMarkdown
                  .replace(/\n[\n]+/g, "\n\n")
                  .split('\n\n');
  var editableSections = [];
  // we also do this inside processSection, but independently track here:
  sections.forEach(function forEachSection(section, index) {
    if (o.isEditable(section, o.preProcessor(o.originalMarkdown))) editableSections.push(section);
  });
  el.html('');
  // we might start running processSections only on editableSections...
  o.processSections(sections, o);
  el.show();
  return {
    element: el,
    sections: sections,
    editableSections: editableSections,
    options: o
  };
}
module.exports = inlineMarkdownEditor;
