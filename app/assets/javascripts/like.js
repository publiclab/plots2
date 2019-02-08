/* Like button functionality of nodes */

// functionalize appearance changes
function changelikecount(node_id) {

  var count = $('#like-count-' + node_id).html();
  // strip parens and convert to number
  count = parseInt(count);
  var previous_like_state = getLikeState();
  var new_like_state = !previous_like_state;
  count += new_like_state - previous_like_state;

  setLikeState(new_like_state);
  // push value back out
  $('#like-count-' + node_id).html(count);

}

function shownotliked(node_id) {
  $('#like-star-' + node_id)[0].className = "fa fa-star-o";
}

function showliked(node_id) {
  $('#like-star-' + node_id)[0].className = "fa fa-star";
}

function setLikeState(new_like_state) {
  window._like_state = new_like_state;
}

function getLikeState() {
  return window._like_state;
}

// support AJAX button clicking
function clickliked() {

  var node_id = $(this).attr('node-id');
  // toggle liked to not liked.
  $.getJSON("/likes/node/" + node_id + "/delete")
   .done(function(response) {
    notyNotification('mint', 3000, 'success', 'topRight', 'Unliked!');
    shownotliked(node_id);
    changelikecount(node_id);
    $('#like-button-' + node_id).on('click', clicknotliked);
    $('#like-button-' + node_id).off('click', clickliked);

  });

}

function clicknotliked() {

  var node_id = $(this).attr('node-id');
  // toggle not liked to liked.
  $.getJSON("/likes/node/" + node_id + "/create")
   .done(function(response) {
    notyNotification('mint', 3000, 'success', 'topRight', 'Liked!');
    showliked(node_id);
    changelikecount(node_id);
    $('#like-button-' + node_id).on('click', clickliked);
    $('#like-button-' + node_id).off('click', clicknotliked);

  });

}
