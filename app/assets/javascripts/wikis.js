function setupWiki(node_id, raw) {

  // insert inline forms
  if (raw) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], { submitUrl: '/wiki/replace/' + node_id }));

    var markdown = megamark(
      $('#content-raw-markdown').html(),
      { 
        sanitizer: {  
          allowedTags: [
            "a", "article", "b", "blockquote", "br", "caption", "code", "del", "details", "div", "em",
            "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "img", "ins", "kbd", "li", "main", "ol",
            "p", "pre", "section", "span", "strike", "strong", "sub", "summary", "sup", "table",
            "tbody", "td", "th", "thead", "tr", "u", "ul", 
            "div", "script", "iframe", "button" // but all classnames are scrubbed
          ],
          allowedAttributes: {
            a: ['class', 'id'],
            div: ['class', 'id']
          },
          allowedClasses: {
            button: ['class'],
            a: ['class'] ,
            div: ['class']
          }
          //"allowedClasses": "class"
        }
      }
    );

    $('#content').html(markdown);
  } else {
    $('#content').html(shortCodePrompt($('#content')[0], { submitUrl: '/wiki/replace/' + node_id }));
  }

  /* setup bootstrap behaviors */
  $("[rel=tooltip]").tooltip()
  $("[rel=popover]").popover({container: 'body'})
  $('table').addClass('table')
  
  $('iframe').css('border','none')
  
  /* add "link" icon to headers */
  $("#content h1, #content h2, #content h3, #content h4").append(function(i,html) {
    return " <small><a href='#" + this.innerHTML.replace(/ /g,'+') + "'><i class='icon fa fa-link'></i></a></small>";
  });

}
