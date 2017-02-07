function setupWiki(node_id, raw) {
  // insert inline forms
  if (raw) {
    $('#content-raw-markdown').html(shortCodePrompt($('#content-raw-markdown')[0], { submitUrl: '/wiki/replace/' + node_id }));
    $('#content').html('');
    var sections = $('#content-raw-markdown').html().split('\n\n');
    sections.forEach(forEachSection);
  } else {
    $('#content').html(shortCodePrompt($('#content')[0], { submitUrl: '/wiki/replace/' + node_id }));
  }

  /* setup bootstrap behaviors */
  $("[rel=tooltip]").tooltip()
  $("[rel=popover]").popover({container: 'body'})
  $('table').addClass('table')

  /* add "link" icon to headers */
  $("#content h1, #content h2, #content h3, #content h4").append(function(i,html) {
    return " <small><a href='#" + this.innerHTML.replace(/ /g,'+') + "'><i class='icon fa fa-link'></i></a></small>";
  });

  function forEachSection(markdown, index) {
    var html     = replaceWithMarkdown(markdown),
        uniqueId = "section-form-" + index;
 
    $('#content').append(html);
    var el = $('#content > *:last');
 
    var editLink = "";
    editLink += "<a class='inline-edit-link inline-edit-link-" + uniqueId + "'><i class='fa fa-pencil'></i></a>";
 
    var formHtml = "<form style='display:none;' class='well' id='" + uniqueId + "'>";
    formHtml += "<p><b>Edit this section:</b></p>";
    formHtml += "<p><textarea rows='6' class='form-control'>" 
    formHtml += markdown + "</textarea></p>";
    formHtml += "<p><button type='submit' class='btn btn-primary'>Save</button> ";
    formHtml += " &nbsp; <a class='cancel'>cancel</a>";
    formHtml += "<small style='color:#aaa;'><i> | In-line editing only works with basic content. For more, edit the whole page.</i></small>";
    formHtml += "</form>";
 
    // filter? Only p,h1-5,ul?
    var isMarkdown = markdown.match(/</) === null; // has tags
 
    if (isMarkdown) {
      el.after(formHtml);
      var form = $('#' + uniqueId);
      el.append(editLink);
      $('.inline-edit-link-' + uniqueId).click(function inlineEditLinkClick(e) {
        e.preventDefault();
        form.toggle();
      });
      form.find('.cancel').click(function inlineEditCancelClick(e) {
        e.preventDefault();
        form.hide();
      });
      form.find('button').click(submitSectionForm);
    }

/*
    function onComplete(response) {
      var message = $('#' + uniqueId + ' .prompt-message');
      if (response === 'true' || response === true) {
        message.html('<i class="fa fa-check" style="color:green;"></i>');
        var input = $('#' + uniqueId + ' .form-control').val();
        var form = $('#' + uniqueId).before('<p>' + input + '</p>');
        $('#' + uniqueId + ' .form-control').val('');
      } else {
        message.html('There was an error. Do you need to <a href="/login">log in</a>?');
      }
    }
 
    function onFail(response) {
      var message = $('#' + uniqueId + ' .prompt-message');
      message.html('There was an error. Do you need to <a href="/login">log in</a>?');
    }
*/

    function submitSectionForm(e) {
      e.preventDefault();
console.log('node_id', node_id)
      $.post("/wiki/replace/" + node_id, {
        before: markdown,
        after: form.find('textarea').val()
      })
//     .done(onComplete)
//     .fail(onFail);
    }
  }
}

function replaceWithMarkdown(element) {
  var markdown = megamark(
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
  return markdown;
}
