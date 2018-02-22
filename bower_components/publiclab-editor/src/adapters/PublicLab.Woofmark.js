/*
 * Wrapped woofmark() constructor with 
 * customizations for our use case.
 * Should improve organization of this vs. RichTextModule
 */

var woofmark     = require('woofmark'),
    domador      = require('domador'),
    megamark     = require('megamark'),
    horsey       = require('horsey'),
    banksy       = require('banksy');
    
module.exports = function(textarea, _editor, _module) {

  var icons = {

    'quote':      'quote-right',
    'ol':         'list-ol',
    'ul':         'list-ul',
    'heading':    'header',
    'attachment': 'paperclip',
    'table':      'table'

  }


  _module.options.tags = _module.options.tags || function(data, done) {
    done(null, [{ list: [
      '#spectrometer', 
      '#air-quality', 
      '#water-quality', 
      '#balloon-mapping' 
    ]}]);
  }


  _module.options.authors = _module.options.authors || function(data, done) {
    done(null, [{ list: [
      { value: '@hodor',  text: '@hodor; 1 note'   },
      { value: '@sansa',  text: '@sansa; 2 notes'  },
      { value: '@john',   text: '@john; 4 notes'   },
      { value: '@rob',    text: '@rob; 1 note'     },
      { value: '@rickon', text: '@rickon; 5 notes' },
      { value: '@bran',   text: '@bran; 1 note'    },
      { value: '@arya',   text: '@arya; 2 notes'   }
    ]}]);
  }


  var wysiwyg = woofmark(textarea, {

    defaultMode: 'wysiwyg',
    storage:     'ple-woofmark-mode',

    render: {

      modes: function (button, id) {

        button.className = 'woofmark-mode-' + id;
        if (id == 'html')     $(button).remove();
        if (id == 'markdown') button.innerHTML = "Markdown";
        if (id == 'wysiwyg')  button.innerHTML = "Rich";

      },

      commands: function (button, id) {

        button.className = 'woofmark-command-' + id;
        var icon = icons[id] || id;
        button.innerHTML = '<i class="fa fa-' + icon + '"></i>';

      }

    },

    images: {

      method: 'POST',
 
      // endpoint where the images will be uploaded to, required
      url: '/images',
 
      // optional text describing the kind of files that can be uploaded
      restriction: 'GIF, JPG, and PNG images',

      // image field key
      fieldKey: 'image[photo]',

      // additional form fields
      formData: { nid: null },

      // xhr upload options like CSRF token
      xhrOptions: { 
        beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')) }
      },

      // should return whether `e.dataTransfer.files[i]` is valid, defaults to a `true` operation
      validate: function isItAnUploadableFile (file) {
        // previously used, just for images:
        // return /^image\/(gif|png|p?jpe?g)$/i.test(file.type);
        // however we found in https://github.com/publiclab/plots2/issues/1561 that woofmark
        // treats "attachments" as footnotes, which do not render in our markdown parsers
        // but we can pass non-image attachments through under "images" and they appear as <a> links
        var valid = true,
            formats = _module.options.formats || ['csv', 'xls', 'zip', 'kml', 'kmz', 'gpx', 'lut', 'stl', 'dxf', 'txt', 'pdf', 'svg', 'doc', 'ppt', 'gif', 'png', 'jpg', 'jpeg'],
            filetype = file.name.split('.')[file.name.split('.').length - 1];
            filetype = filetype.toLowerCase();
        if (formats.indexOf(filetype) === -1) valid = false;
        return valid;
      }

    },

    parseMarkdown: function (input) {

      _module.scrollTop = document.body.scrollTop;

      return megamark(input, {
        sanitizer: {
          allowedTags: [ "a", "article", "b", "blockquote", "br", "caption", "code", "del", "details", "div", "em",
                         "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "img", "ins", "kbd", "li", "main", "ol",
                         "p", "pre", "section", "span", "strike", "strong", "sub", "summary", "sup", "table",
                         "tbody", "td", "th", "thead", "tr", "u", "ul", "iframe" ],

          allowedAttributes: {
            a: ['href', 'name', 'target', 'title', 'aria-label'],
            iframe: ['allowfullscreen', 'frameborder', 'src', 'width', 'height', 'style', 'border'],
            img: ['src', 'alt', 'title', 'aria-label']
          },
        },
        tokenizers: [
          {
            token: /(^|\s)@([A-z\_]+)\b/g, // @callouts
            transform: function (all, separator, id) {
              return separator + '<a href="/profile/' + id + '">@' + id + '</a>';
            }
          },
          {
            token: /(^|\s)#([A-z\-]+)\b/g, // #hashtags
            transform: function (all, separator, id) {
              return separator + '<a href="/tag/' + id + '">#' + id + '</a>';
            }
          }
        ]
      });

    },

    parseHTML: function (input) {

      _module.scrollTop = document.body.scrollTop;

      return domador(input, {
        allowFrame: true,
        inline: true,
        fencing:   true,
        fencinglanguage: function (el) {
          var match = el.className.match(/md-lang-((?:[^\s]|$)+)/);
          if (match) {
            return match.pop();
          }
        },
        transform: function (el) {

          if (el.tagName === 'IFRAME') {
            return '\n\n\n' + el.outerHTML;
          }

          if (el.tagName === 'A' && el.innerHTML[0] === '@') {
            return el.innerHTML;
          }

          if (el.tagName === 'A' && el.innerHTML[0] === '#') {
            return el.innerHTML;
          }

        }
      });

    } 

  });


  // allow toggling off:
  if (_module.options.authorsAutocomplete !== false) {

    wysiwyg.calloutHorse = horsey(wysiwyg.editable, {
      anchor: '@',
      source: _module.options.authors,
      getText: 'text',
      getValue: 'value'
    });
 
    wysiwyg.calloutHorse.defaultSetter = function (value) {
      if (wysiwyg.mode === 'wysiwyg') {
        textarea.innerHTML = value;
      } else {
        textarea.value = value;
      }
    }
 
    wysiwyg.calloutBridge = banksy(textarea, {
      editor: wysiwyg,
      horse: wysiwyg.calloutHorse
    });

  }

  if (_module.options.tagsAutocomplete !== false) {

    wysiwyg.tagHorse = horsey(textarea, {
      anchor: '#',
      source: _module.options.tags
    });
 
    wysiwyg.tagHorse.defaultSetter = function (value) {
      el.value = value + ', ';
    }
 
    wysiwyg.tagBridge = banksy(textarea, {
      editor: wysiwyg,
      horse: wysiwyg.tagHorse
    });

  }


  // set up table generation tools:
  require('../modules/PublicLab.RichTextModule.Table.js')(_module, wysiwyg);

  // set up horizontal rule insertion tool:
  require('../modules/PublicLab.RichTextModule.HorizontalRule.js')(_module, wysiwyg);

  // set up embed insertion tool:
  require('../modules/PublicLab.RichTextModule.Embed.js')(_module, wysiwyg);

  wysiwyg.stylePrompt = function() {
    $('.wk-prompt button, span.wk-prompt-browse').addClass('btn btn-default');
    $('.wk-prompt input').addClass('input form-control')
                         .css('margin-bottom','5px');
  }

  $('.wk-commands button.woofmark-command-attachment, .wk-commands button.woofmark-command-image').click(wysiwyg.stylePrompt);


  wysiwyg.style = function() {

    $('.wk-commands').after('&nbsp; <span style="color:#888;display:none;" class="ple-history-saving btn"><i class="fa fa-clock-o"></i> <span class="hidden-xs">Saving...</span></span>');
    $('.wk-commands, .wk-switchboard').addClass('btn-group');
    $('.wk-commands button, .wk-switchboard button').addClass('btn btn-default');
 
    $('.wk-commands button.woofmark-command-quote').addClass('hidden-xs');
    $('.wk-commands button.woofmark-command-code').addClass('hidden-xs');
    $('.wk-commands button.woofmark-command-ol').addClass('hidden-xs');
    $('.wk-commands button.woofmark-command-attachment').addClass('hidden-xs');
 
    $('.wk-switchboard button.woofmark-mode-markdown').parent().removeClass('btn-group');
    $('.wk-switchboard button.woofmark-mode-markdown').html('<span class="visible-xs">#</span><span class="hidden-xs">Markdown</span>');
    $('.wk-switchboard button.woofmark-mode-wysiwyg').html('<span class="visible-xs">Aa</span><span class="hidden-xs">Rich</span>');
 
    if (wysiwyg.mode === 'wysiwyg') $('.wk-switchboard button.woofmark-mode-wysiwyg').hide();
    else                            $('.wk-switchboard button.woofmark-mode-markdown').hide();
 
    $('.wk-switchboard button').click(function() {
      $('.wk-switchboard button.woofmark-mode-markdown').toggle();
      $('.wk-switchboard button.woofmark-mode-wysiwyg').toggle();
    });
 
    if (_editor.options.size == "xs") {
 
      //$('.wk-switchboard button,.wk-commands button').addClass('btn-xs');
 
      // hide selectively, not by #:
      $('.wk-commands button.woofmark-command-quote').hide();
      $('.wk-commands button.woofmark-command-code').hide();
      $('.wk-commands button.woofmark-command-ol').hide();
      $('.wk-commands button.woofmark-command-ul').hide();
 
    } else {
 
      $('.wk-switchboard button').addClass('btn-sm');
 
    }

  }


  wysiwyg.style();

  return wysiwyg;

}
