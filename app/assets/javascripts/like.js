/* eslint-disable no-empty-label */
/* Like button functionality of nodes */

function clickliked() {
  var node_id = $(this).attr('node-id');
  changeLikeStatus(node_id, "/delete");
}

function clicknotliked() {
  var node_id = $(this).attr('node-id');
  changeLikeStatus(node_id, "/create");
}

function changeLikeStatus(node_id, method) {
  $('#like-button-' + node_id).off();
  $.getJSON("/likes/node/" + node_id + method)
    .then(function(resp) {
      updateLikeCount(parseInt(resp), node_id);
      renderLikeStar(parseInt(resp), node_id);
      displayNotyNotification(method);
    })
    .then(function(resp) {
      let method1 = method === "/delete" ? clicknotliked : clickliked
      $('#like-button-' + node_id).on('click', method1);
    });
}

function displayNotyNotification(method) {
  let text, type;
  if (method === "/create") {
    text = "Note Liked!";
    type = "info";
  } else {
    text = "Note Unliked!";
    type = "error";
  }
  notyNotification('relax', 3000, type, 'topRight', text);
}

function updateLikeCount(value, node_id) {
  var count = $('#like-count-' + node_id).html();
  count = parseInt(count) + value;
  $('#like-count-' + node_id).html(count);
}

// where fa fa-star-o is a clear star (indicating you are not currently liking)
function renderLikeStar(value, node_id) {
  let name = value === -1 ? "fa fa-star-o" : "fa fa-star"
  $('#like-star-' + node_id)[0].className = name;
}
