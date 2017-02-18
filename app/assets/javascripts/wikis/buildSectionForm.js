function buildSectionForm(uniqueId, contents) {
  var formHtml = "<form style='display:none;' class='well' id='" + uniqueId + "'>";
  formHtml += "<p><b>Edit this section:</b></p>";
  formHtml += "<p><textarea rows='6' class='form-control'>" 
  formHtml += contents + "</textarea></p>";

  formHtml += "<button type='submit' class='btn btn-primary submit'>Save</button> ";

  formHtml += "<span class='btn-group'>";
  formHtml += "  <button class='btn btn-default dropdown-toggle' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>Insert <b class='caret'></b></button>";
  formHtml += "  <ul class='dropdown-menu'>";
  formHtml += "    <li><a class='insert-notes-grid'>Tag-based notes grid</a></li>";
  formHtml += "    <li><a class='insert-questions-grid'>Q&A section</a></li>";
  formHtml += "    <li><a class='insert-activities-grid'>Activities grid</a></li>";
  formHtml += "    <li><a href='/wiki/power-tags' target='_blank'>Read about power tags</a></li>";
  formHtml += "  </ul>";
  formHtml += "</span> ";

  formHtml += "&nbsp; <a class='cancel'>cancel</a>";
  formHtml += "<small style='color:#aaa;'><i> | <span class='section-message'>In-line editing only works with basic content. Content may require page refresh.</span></i></small>";
  formHtml += "</form>";
  return formHtml;
}
