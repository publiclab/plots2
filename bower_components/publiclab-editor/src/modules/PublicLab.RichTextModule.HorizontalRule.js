/* 
   Horizontal Rule insertion: ****
*/   

module.exports = function initHorizontalRule(_module, wysiwyg) {

  // create a menu option for horizontal rules:
  $('.wk-commands').append('<a class="woofmark-command-horizontal-rule btn btn-default"><i class="fa fa-ellipsis-h"></i></a>');

  $('.wk-commands .woofmark-command-horizontal-rule').click(function() {
    wysiwyg.runCommand(function(chunks, mode) {
      chunks.before += _module.wysiwyg.parseMarkdown("\n****\n"); // newlines before and after
      _module.afterParse(); // tell editor we're done here
  
      // setTimeout(_module.afterParse, 0); // do this asynchronously so it applies Boostrap table styling

    });

  });

}
