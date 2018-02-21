/* 
   Embed insertion: <iframe width="560" height="315" src="https://www.youtube.com/embed/Ej_l1hANqMc" frameborder="0" allowfullscreen></iframe>
*/   

module.exports = function initEmbed(_module, wysiwyg) {

  // create a menu option for embeds:
  $('.wk-commands').append('<a class="woofmark-command-embed btn btn-default"><i class="fa fa-youtube"></i></a>');

  $('.wk-commands .woofmark-command-embed').click(function() {
    wysiwyg.runCommand(function(chunks, mode) {
      chunks.before += _module.wysiwyg.parseMarkdown("\n\n\n" + prompt("Enter the full embed code offered by the originating site; for YouTube, that might be: <iframe width='100%' src='https://youtube.com/embed/_________' frameborder='0' allowfullscreen></iframe>") + "\n"); // newlines before and after
      _module.afterParse(); // tell editor we're done here
    });

  });

}
