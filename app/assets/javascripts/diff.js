
  <div class="well" id="diff"></div>

</div>

  <style>
    del { background:#faa; }
    ins { background:#afa; }
  </style>


jQuery(document).ready(function() {
  $('#diff').html(diffString(a,b));
  $(document).keydown(function(e){ if (e.keyCode == 39) { next() }})
  $(document).keydown(function(e){ if (e.keyCode == 37) { prev() }})
  function prev() {
    if (older > 0) {
      goto(newer-1,older-1)
  }}
  function next() {
    if (newer < <%= @node.revisions.length-1 %>) {
      goto(newer+1,older+1)
  }}
  function goto(newr,old) {
    newer = newr
    older = old
    $('#newer').html(newer)
    $('#older').html(older)
    $('#diff').html(diffString($('#body_'+older).html(),$('#body_'+newer).html()))
    $('tr').removeClass('warning')
    $('#row'+older).addClass('warning')
    $('#row'+newer).addClass('warning')
  }
});
