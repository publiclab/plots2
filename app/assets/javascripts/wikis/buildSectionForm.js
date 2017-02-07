function buildSectionForm(uniqueId, contents) {
  var formHtml = "<form style='display:none;' class='well' id='" + uniqueId + "'>";
  formHtml += "<p><b>Edit this section:</b></p>";
  formHtml += "<p><textarea rows='6' class='form-control'>" 
  formHtml += contents + "</textarea></p>";
  formHtml += "<p><button type='submit' class='btn btn-primary'>Save</button> ";
  formHtml += " &nbsp; <a class='cancel'>cancel</a>";
  formHtml += "<small style='color:#aaa;'><i> | <span class='section-message'>In-line editing only works with basic content. For more, edit the whole page.</span></i></small>";
  formHtml += "</form>";
  return formHtml;
}
