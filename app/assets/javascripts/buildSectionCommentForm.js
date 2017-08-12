function buildSectionCommentForm(uniqueId, title, current_user) {
  var formHtml = "<form style='display:none;' id='inline-comment-"+uniqueId+"' data-remote='true' class='well' action='/comment/__action___/___node_id___'>";
  formHtml += "<h4 style='margin-top:0; padding-top:0;'>"+title+"</h4>";
  formHtml += "<style> #imagebar {width:100%;}</style>" 
  formHtml += "<div class='form-group dropzone'>";

  formHtml += "<textarea onFocus='editing=true' name='body' class='form-control' id='text-input' rows='6' cols='40' placeholder='Help" 
  formHtml += " the authors refine this wiki subsection, or point them at other helpful information on the site. Mention users by @username to notify them of this thread by email'></textarea>";
  formHtml += "<div id='imagebar'>";

  formHtml += "<div id='create_progress' style='display:none;' class='progress progress-striped active pull-right'>"; 
  formHtml += "<div id='create_progress-bar' class='progress-bar' style='width: 0%;''></div>";
  formHtml += "</div><p>";
  
  formHtml += "<span id='create_uploading' class='uploading' style='display:none;'>";
  formHtml += "uploading";
  formHtml += "</span>";

  formHtml += "<span id='create_prompt' class='prompt'>";
  formHtml += "<span style='padding-right:4px;float:left;' class='hidden-xs'>";
  formHtml += "Drag & drop to add an image or file, or";
  formHtml += "</span>";

  formHtml += "<label id='input_label' class='' for='fileinput'>";
  formHtml += "<input id='fileinput' type='file' name='image[photo]' style='display:none;' />";
  formHtml += "<a class='hidden-xs'>choose one</a>";
  formHtml += "<span class='visible-xs'>";
  formHtml += "<i class='fa fa-upload'></i> ";
  formHtml += " <a>upload_image</a>";
  formHtml += "</span></label></span></p></div></div>";
  formHtml += "<div class='well col-md-11' id='preview' style='background:white;display: none'></div>";

  formHtml += "<div class='control-group'>";
  formHtml += "<button type='submit' class='btn btn-primary'>Publish</button> ";
  formHtml += "<a id='preview-btn' class='btn btn-default'>Preview</a>";
  formHtml += "<span style='color:#888;'> &nbsp; ";
  formHtml += "<br class='visible-xs' />Logged in as "+current_user+" | ";
  formHtml += "<a target='_blank' href='/wiki/authoring-help#Formatting'>Formatting</a> | ";
  formHtml += "<a onClick='$('#who-is-notified-form').toggle()'>Notifications</a>";
  formHtml += "</span>";
  formHtml += "</div>";
  formHtml += "<p id='who-is-notified-form' style='display:none;color:#888;'>";
  formHtml += "<%= t('comments._form.email_notifications') %>";
  formHtml += "</p>";

  formHtml += "</form>";
  return formHtml;
}