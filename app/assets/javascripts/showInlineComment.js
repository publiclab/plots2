function showInlineComment(cid, comment) {

var iComment = "<div id='inline-comment-"+cid+"' style='padding-top: 10px;'>";
iComment += "<div class='inline' style='vertical-align: top;'>";
// iComment += "<% if comment.author.user && comment.author.user.photo_file_name %>";
// iComment += "<img class='img-circle' src='<%= comment.author.user.photo_path(:thumb) %>' />"; 
// iComment += "<% else %>";
iComment += "<div class='img-circle'></div>";
// iComment += "<% end %>";
iComment += "</div>";

iComment += "<div class='inline' id='comment-content'>";
//iComment += "<a href='/profile/<%= comment.author.name %>'><%= comment.author.name %></a>";
//iComment += "<span class='hidden-xs'>commented </span>";
//iComment += "<a style='color:#aaa;' href='#answer-<%= answer_id %>-comment-<%= comment.id %>'><%= time_ago_in_words(comment.created_at) %> ago</a><br/>";
iComment += "<span class='content'>";
iComment += comment;
iComment += "</span>";
iComment += "</div>";

// iComment += "<div class='inline pull-xs-right' style='vertical-align: top'>";
// iComment += "<p><% if current_user && current_user.uid == comment.uid %>";
// iComment += "<a class='btn btn-default btn-sm' onClick='$('#answer-<%= answer_id %>-comment-<%= comment.id %> .content').toggle();$('#answer-<%= answer_id %>-comment-<%= comment.id %> .content-form').toggle();' ><i class='fa fa-pencil'></i></a>";
// iComment += "<% end %>";
// iComment += "<% if current_user && (current_user.role == 'admin' || current_user.role == 'moderator' || comment.uid == current_user.uid || node.uid == current_user.uid) %>";
// iComment += "<a class='btn btn-default btn-sm' id='answer-<%= answer_id %>-comment-<%= comment.id %>-delete-btn' data-remote='true' data-confirm='Are you sure? <% if current_user && comment.uid != current_user.uid %>Please exercise caution in deleting/moderating others' comments; this cannot be undone.<% end %>' href='/comment/delete/<%= comment.id %>?type=question'><i class='icon fa fa-trash'></i></a>";
// iComment += "<% end %></p>";
// iComment += "</div>";
iComment += "</div>";

return iComment;
}