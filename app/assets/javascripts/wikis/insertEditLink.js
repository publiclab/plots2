function insertEditLink(uniqueId, el, form) {
  var editBtns = "";
  editBtns += "<span class='inline-edit-btns inline-edit-btns-" + uniqueId + "'>";
  editBtns +=   "<a class='inline-edit-btn inline-edit-link inline-edit-link-" + uniqueId + "'><i class='fa fa-pencil'></i></a>";
  // editBtns +=   "<a class='inline-edit-btn inline-edit-image inline-edit-image-" + uniqueId + "'><i class='fa fa-image'></i></a>";
  editBtns +=   "<i>Edit the above section</i>";
  editBtns += "</span>";
  el.append(editBtns);
  $('.inline-edit-link-' + uniqueId).click(function inlineEditLinkClick(e) {
    e.preventDefault();
    form.toggle();
  });
}
