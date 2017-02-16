// Runs megamark with default whitelist
function replaceWithMarkdown(element) {
  var html = megamark(
    element,
    { 
      sanitizer: {  
        allowedTags: [
          "a", "article", "b", "blockquote", "br", "caption", "code", "del", "details", "div", "em",
          "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "img", "ins", "kbd", "li", "main", "ol",
          "p", "pre", "section", "span", "strike", "strong", "sub", "summary", "sup", "table",
          "tbody", "td", "th", "thead", "tr", "u", "ul", 
          "form", "input", "textarea", "div", "script", "iframe", "button"
        ],
        allowedAttributes: {
          a: ['class', 'id', 'href'],
          button: ['class', 'id'],
          div: ['class', 'id'],
          form: ['class', 'id'],
          input: ['class', 'id', 'name', 'placeholder'],
          textarea: ['class', 'id', 'name', 'placeholder'],
          iframe: ['class', 'id', 'src']
        },
        allowedClasses: {
          button: ['class'],
          input: ['class'],
          a: ['class'] ,
          div: ['class']
        }
        //"allowedClasses": "class"
      }
    }
  );
  html = addCallouts(html);
  html = addHashtags(html);
  return html;
}
