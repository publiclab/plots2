function showInlineComment(cid, comment, photo_file_name, author_photo_path, author_name, created_at, uid ) {
  var iComment = "<div id='inline-comment-"+cid+"' style='padding-top: 10px; padding-left: 10px;'>";
  iComment += "<div class='inline' style='vertical-align: top;'>";
  if(photo_file_name){
    iComment += "<img class='img-circle' src='"+author_photo_path+"' />";
  }else{
    iComment += "<div class='img-circle'></div>";
  }
  iComment += "</div>";

  iComment += "<div class='inline' id='comment-content'>";
  iComment += "<a href='/profile/"+author_name+"'>"+author_name+"</a>";
  iComment += "<span class='hidden-xs'> commented </span>";
  iComment += "<a style='color:#aaa;' href='#inline-comment-"+cid+"'>on "+created_at+"</a><br/>";
  iComment += "<span class='content'>";
  iComment += comment;
  iComment += "</span>";
  iComment += "</div>";

  iComment += "<div class='inline pull-xs-right' style='vertical-align: top'>";
  // if(current_user.id == uid){
  //   iComment += "<a class='btn btn-default btn-sm'><i class='fa fa-pencil'></i></a>";
  // }
  // if(current_user.role == 'admin' || current_user.role == 'moderator' || uid == current_user.id || node.uid == current_user.id){
  //   if(uid == current_user.id){
  //     console.log("in in");
  //     iComment += "<a class='btn btn-default btn-sm' id='inline-comment-"+cid+"-delete-btn' data-remote='true' data-confirm='Are you sure?' href='/comment/delete/"+cid+"'><i class='icon fa fa-trash'></i></a>";
  //   }else{
  //     iComment += "<a class='btn btn-default btn-sm' id='inline-comment-"+cid+"-delete-btn' data-remote='true' data-confirm='Are you sure? Please exercise caution in deleting/moderating others comments, this cannot be undone' href='/comment/delete/"+cid+"'><i class='icon fa fa-trash'></i></a>";
  //   }
  // }
  iComment += "</p></div>";
  iComment += "</div>";

  return iComment;
}