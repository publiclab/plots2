module.exports = function processSections(sections, o) {
  sections.forEach(function(markdown) {
    processSection = require('./processSection.js');
    processSection(markdown, o);
  });
}
