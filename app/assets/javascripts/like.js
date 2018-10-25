/* Like button functionality of nodes */

// functionalize appearance changes
function toggleLikeCount(node_id) {
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

function showNotLiked(node_id) {
  $('#like-star-' + node_id)[0].className = "fa fa-star-o";
}

function showLiked(node_id) {
  $('#like-star-' + node_id)[0].className = "fa fa-star";
}


function setLikeState(new_like_state) {
  window._like_state = new_like_state;
}

function getLikeState() {
  return window._like_state;
}

function toggleLike() {
  var previously_liked_state = getLikeState();
  var node_id = $(this).attr('node-id');
  var endpoint = previously_liked_state ? 'delete' : 'create';

  $.getJSON(`/likes/node/${node_id}/${endpoint}`)
    .done(function(response) {
      // Refetch the state since it's callback function and value
      // might got updated.
      var previously_liked = getLikeState();
      var message = previously_liked ? 'Unliked!' : 'Liked!';
      notyNotification('mint', 3000, 'success', 'topRight', message);
      if (previously_liked) {
        showNotLiked(node_id);
      } else {
        showLiked(node_id);
      }
      toggleLikeCount(node_id);
  });
}
