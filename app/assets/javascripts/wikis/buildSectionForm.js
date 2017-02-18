function buildSectionForm(uniqueId, contents) {
  var formHtml = "<form style='display:none;' class='well inline-edit-form' id='" + uniqueId + "'>";
  formHtml += "<p><b>Edit this section:</b></p>";
  formHtml += "<p><textarea rows='6' class='form-control'>" 
  formHtml += contents + "</textarea></p>";
  formHtml += "<p><button type='submit' class='btn btn-primary'>Save</button> ";

  formHtml += "<span class='btn-group'>";
  formHtml += "<button type='submit' class='btn btn-default dropdown-toggle' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>Insert</button> ";
  formHtml += "  <ul class='dropdown-menu'>";
  formHtml += "    <li><a href="#">Action</a></li>
  formHtml += "  </ul>
  formHtml += "</span>

  formHtml += " &nbsp; <a class='cancel'>cancel</a>";
  formHtml += "<small style='color:#aaa;'><i> | <span class='section-message'>In-line editing only works with basic content. For more, edit the whole page.</span></i></small>";
  formHtml += "</form>";
  return formHtml;
}
