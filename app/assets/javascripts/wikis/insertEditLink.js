function insertEditLink(uniqueId, el, form) {
  var editLink = "";
  editLink += "<a class='inline-edit-link inline-edit-link-" + uniqueId + "'><i class='fa fa-pencil'></i></a>";
  el.append(editLink);
  $('.inline-edit-link-' + uniqueId).click(function inlineEditLinkClick(e) {
    e.preventDefault();
    form.toggle();
  });
}
