function setupSectionForm(uniqueId) {
  [
    'notes',
    'questions',
    'activities'
  ].forEach(function(type) {
    setupInsertMenuOption(uniqueId, type);
  });
}

function setupInsertMenuOption(uniqueId, type) {
  $('#' + uniqueId + ' .insert-' + type + '-grid').click(function insertNotesGrid() {
    var tagname = prompt("Enter a tag name to collect content for this grid.");
    if (tagname) {
      var textarea = $('#' + uniqueId + ' textarea');
      var content = textarea.val();
      content += "\n\n[" + type + ":" + tagname + "]";
      textarea.val(content);
    }
  });
}
