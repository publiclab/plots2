/* Like button functionality of nodes */
function getnode(node){
  return node.attr('node-id'); // get current node
}
// functionalize appearance changes
function changelikecount(value, node_id) {

  var count = $('#like-count-' + node_id).html();
  // strip parens and convert to number
  count = parseInt(count);
  count += value;
  // push value back out
  $('#like-count-' + node_id).html(count);

}

function shownotliked(node_id) {

  $('#like-star-' + node_id)[0].className = "fa fa-star-o";

}

function showliked(node_id) {

  $('#like-star-' + node_id)[0].className = "fa fa-star";

}

// support AJAX button clicking
function clickliked() {

  var node_id = getnode($(this));
  // toggle liked to not liked.
  $.getJSON("/likes/node/" + node_id + "/delete")
   .done(function(response) {
    notyNotification('mint', 3000, 'success', 'topRight', 'Unliked!');
    shownotliked(node_id);
    changelikecount(parseInt(response), node_id);
    $('#like-button-' + node_id).on('click', clicknotliked);
    $('#like-button-' + node_id).off('click', clickliked);
    insertusername(response)
  });

}

function clicknotliked() {

  var node_id = getnode($(this));
  // toggle not liked to liked.
  $.getJSON("/likes/node/" + node_id + "/create")
   .done(function(response) {
    notyNotification('mint', 3000, 'success', 'topRight', 'Liked!');
    showliked(node_id);
    changelikecount(parseInt(response), node_id);
    $('#like-button-' + node_id).on('click', clickliked);
    $('#like-button-' + node_id).off('click', clicknotliked);
    insertusername(response)
  });

}

function insertusername(response){
  if(parseInt(response) === 1){
      username = document.getElementById('current-username').textContent;
      html = $("li#users").attr("data-content");
      html = html.replace("<div id='liked-this'></div>", "<div id='liked-this'><i class='fa fa-star-o'></i><a href='/profile/"+username+"/'>"+username+"</a></div>");
      $("li#users").attr("data-content", html);
    }
}
