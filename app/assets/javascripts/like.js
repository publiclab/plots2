/* Like button functionality of nodes */

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

  var node_id = $(this).attr('node-id');
  // toggle liked to not liked.
   $.ajax({
    url: "/likes/node/" + node_id + "/delete",
    type: 'DELETE',
    success: function(response) {
     shownotliked(node_id);
     changelikecount(parseInt(response), node_id);
     $('#like-button-' + node_id).on('click', clicknotliked);
     $('#like-button-' + node_id).off('click', clickliked);
    }
});

}

function clicknotliked() {

  var node_id = $(this).attr('node-id');
  // toggle not liked to liked.
  $.getJSON("/likes/node/" + node_id + "/create")
   .done(function(response) {

     showliked(node_id);
     changelikecount(parseInt(response), node_id);
     $('#like-button-' + node_id).on('click', clickliked);
     $('#like-button-' + node_id).off('click', clicknotliked);
 
   });

}
