module.exports = function isEditable(markdown, originalMarkdown) {
  originalMarkdown = originalMarkdown || markdown; // optional parameter for checking against original complete text
  // filter? Only p,h1-5,ul?
  var editable = markdown.match(/</) === null; // has tags; exclueds HTML
  editable = editable && markdown.match(/\*\*\*\*/) === null; // no horizontal rules: ****
  editable = editable && markdown.match(/\-\-\-\-/) === null; // no horizontal rules: ----
  editable = editable && markdown !== ''; // no blanks
  // here we disallow if more than one instance in original string:
  editable = editable && originalMarkdown.split(markdown).length === 2 // couldn't get match options to work with string
  return editable;
} 
