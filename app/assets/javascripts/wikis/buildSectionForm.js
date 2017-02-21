function buildSectionForm(uniqueId, contents) {
  var formHtml = "<form style='display:none;' class='well inline-edit-form' id='" + uniqueId + "'>";
  formHtml += "<p><b>Edit this section:</b></p>";
  formHtml += "<p><textarea rows='6' class='form-control'>" 
  formHtml += contents + "</textarea></p>";

  formHtml += "<p class='controls'>";
  formHtml += "<button type='submit' class='btn btn-primary submit'>Save</button> ";

  formHtml += "&nbsp; <a class='cancel'>cancel</a>";
  formHtml += "<small style='color:#aaa;'><i> | <span class='section-message'>In-line editing only works with basic content. Content may require page refresh.</span></i></small>";
  formHtml += "</p>";
  formHtml += "</form>";
  return formHtml;
}
