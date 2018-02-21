module.exports = function insertEditLink(uniqueId, el, form, onEdit, editor, o) {
  var editBtns = "";
  editBtns += "<span class='inline-edit-btns inline-edit-btns-" + uniqueId + "'>";
  editBtns +=   "<a class='inline-edit-btn inline-edit-btn-editor-" + uniqueId + " inline-edit-btn-" + uniqueId + "'><i class='fa fa-pencil'></i></a>";
  if (o.extraButtons) {
    Object.keys(o.extraButtons).forEach(function(key, index) {
      editBtns +=   "<a class='inline-edit-btn inline-edit-btn-" + key + " inline-edit-btn-" + uniqueId + " inline-edit-btn-" + uniqueId + "-" + key + "'><i class='fa " + key + "'></i></a>";
    });
  }
  editBtns += "</span>";
  el.append(editBtns);
  if (o.extraButtons) {
    Object.keys(o.extraButtons).forEach(function(key, index) {
    // run respective functions and pass in the elements
    o.extraButtons[key]($('.inline-edit-btn-' + uniqueId + '-' + key), uniqueId);
    });
  }
  $('.inline-edit-btn-editor-' + uniqueId).click(function inlineEditLinkClick(e) {
    e.preventDefault();
    form.toggle();
    if (onEdit) onEdit(); // callback
  });
}
