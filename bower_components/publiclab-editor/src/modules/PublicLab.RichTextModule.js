/*
 * Form module for rich text entry
 */

var crossvent = require('crossvent');

module.exports = PublicLab.RichTextModule = PublicLab.Module.extend({

  init: function(_editor, options) {

    var _module = this;

    _module.key = 'body';
    _module.options = options || _editor.options.richTextModule || {};
    _module.options.name = "body";
    _module.options.instructions = "Guide others through the steps to reproduce your work.";

    // break into subclass common to all modules, perhaps:
    _module.options.guides = [
      { 
        icon: "mouse-pointer", 
        position: 30, 
        text: "Drag images into the text area to upload them."
      },
      { 
        icon: "list-ul",
        position: 90, 
        text: "Be sure to list required materials and resources."
      },
      { 
        icon: "clock-o",
        position: 90, 
        text: "Your work is auto-saved so you can return to it in this browser. To recover drafts, open the <code>...</code> menu below."
      }
    ];


    _module._super(_editor, _module.options);

    // customize options after Module defaults set in _super()
    _module.options.initialValue = _editor.options[_module.key] || _module.el.find('textarea').val();
    _module.options.required = true;

    // should be switchable for other editors:
    _module.wysiwyg = _module.options.wysiwyg || PublicLab.Woofmark(_module.options.textarea, _editor, _module);

    _module.editable = _module.wysiwyg.editable;
    _module.textarea = _module.wysiwyg.textarea;

    if (_module.wysiwyg.mode == "wysiwyg") _module.focusables.push($(_module.editable));
    else                                   _module.focusables.push($(_module.textarea));

    _module.value = function(text) {

      // woofmark automatically returns the markdown, not rich text:
      if (typeof text === 'string') {
        if (_module.afterParse) _module.afterParse();
        return _module.wysiwyg.value(text);
      } else {
        return _module.wysiwyg.value();
      }

    }

    _module.value(_module.options.initialValue);


    _module.valid = function() {

      return _module.value() != "";

    }


    _module.html = function() {

      return _module.wysiwyg.editable.innerHTML;

    }


    _module.markdown = function() {

      return _module.value();

    }


    // converts to markdown and back to html, or the reverse,
    // to trigger @callouts and such formatting
    _module.parse = function() {

      _module.value(_module.value());
      _module.afterParse();

    }


    // construct HTML additions
    _module.build();


    _module.afterParse = function() {

      // bootstrap styling for plots2
      $(_module.wysiwyg.editable).find('table').addClass('table');

    }
    _module.afterParse();


    _module.setMode = function(mode) {

      return _module.wysiwyg.setMode(mode);

    }


    _module.height = function() {

      var height;

      if (_module.wysiwyg.mode == "wysiwyg") height = $('.wk-wysiwyg').height();
      else                                   height = $('.ple-textarea').height();

      return height;

    }


    var growTextarea = require('grow-textarea');

    // Make textarea match content height
    _module.resize = function() {

      growTextarea(_module.options.textarea, { extra: 10 });

    }

    _module.resize();

    crossvent.add(_module.options.textarea, 'blur', function (e) {
      _editor.validate();
    });

    crossvent.add(_module.options.textarea, 'keydown', function (e) {
      _editor.validate();
    });

    crossvent.add(_module.wysiwyg.editable, 'blur', function (e) {
      _editor.validate();
    });

    crossvent.add(_module.wysiwyg.editable, 'keydown', function (e) {
      _editor.validate();
    });

    // once woofmark's done with the textarea, this is triggered
    // using woofmark's special event system, crossvent
    // -- move this into the Woofmark adapter initializer
    crossvent.add(_module.options.textarea, 'woofmark-mode-change', function (e) {

      _module.resize();

      _module.afterParse();

      // ensure document is scrolled to the same place:
      document.body.scrollTop = _module.scrollTop;
      // might need to adjust for markdown/rich text not 
      // taking up same amount of space, if menu is below _editor...
      //if (_editor.wysiwyg.mode == "markdown") 

      if (_module.wysiwyg.mode == "wysiwyg") _module.focusables[0] = $(_module.editable);
      else                                   _module.focusables[0] = $(_module.textarea);

    });

    $(_module.options.textarea).on('change keydown', function(e) {
      _module.resize();
    });


  }

});
