function insertEditLink(uniqueId, el, form, onEdit, editor) {
  var editBtns = "";
  editBtns += "<span class='inline-edit-btns inline-edit-btns-" + uniqueId + "'>";
  editBtns +=   "<a class='inline-edit-btn inline-edit-link inline-edit-link-" + uniqueId + "'><i class='fa fa-pencil'></i></a>";
  // editBtns +=   "<a class='inline-edit-btn inline-edit-image inline-edit-image-" + uniqueId + "'><i class='fa fa-image'></i></a>";
  editBtns +=   "<i>Edit</i>";
  editBtns += "</span>";
  el.append(editBtns);
  $('.inline-edit-link-' + uniqueId).click(function inlineEditLinkClick(e) {
    e.preventDefault();
    form.toggle();
    if (onEdit) {
      if ($('#' + uniqueId).find('.wk-container').length === 0) {
        // insert rich editor
        editor = new PL.Editor({
          textarea: $('#' + uniqueId + ' textarea')[0]
        });
      }
      onEdit(editor); // send it back for later use
    }
  });
}
