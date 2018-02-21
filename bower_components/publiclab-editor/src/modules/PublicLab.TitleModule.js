/*
 * Form module for post title
 */

module.exports = PublicLab.TitleModule = PublicLab.Module.extend({

  init: function(_editor, options) {

    var _module = this;

    _module.key = 'title';
    _module.options = options || _editor.options.titleModule || {};
    _module.options.name = "title";

    // override defaults in TitleModule.Related:
    _module.options.suggestRelated = _module.options.suggestRelated === true || false; // boolean
    _module.options.fetchRelated = _module.options.fetchRelated || false; // expects function

    _module._super(_editor, _module.options);

    _module.focusables.push(_module.el.find('input'));

    _module.options.initialValue = _editor.options[_module.key] || _module.el.find('input').val();
    _module.options.required     = true;
    _module.options.instructions = 'Titles draw others into your work. Choose one that provides some context. <a href="" target="_blank">Read more &raquo;</a>';

    _module.value = function(text) {

      if (typeof text == 'string') {

        _module.el.find('input').val(text);

      }

      return _module.el.find('input').val();

    }

    _module.value(_module.options.initialValue);


    _module.error = function(text, type) {

      type = type || 'error';

      _module.el.find('.ple-module-content .ple-help-minor')
                .html(text);
      _module.el.find('input').parent()
                .addClass('has-' + type);

    }


    _module.valid = function() {

      // must not be empty, for starters
      var value = _module.value(),
          valid = (value != "");

      //valid = valid && (value.match(/\.|,|"|'/) == null);
      // we could discourage too much punctuation, or titles that are too long, here

      if (!valid && value != "") {

        _module.error('Must be formatted correctly.');
 
      } else if (value && value.length > 45) {

        _module.error('Getting a bit long!', 'warning');

      } else {

        _module.el.find('.ple-module-content .ple-help-minor')
                  .html(_module.options.instructions);
        _module.el.find('input').parent()
                  .removeClass('has-error')
                  .removeClass('has-warning');

      }

      return valid;

    }


    // Overrides default build method
    _module.build = function() {    

      // custom location -- just under the title input
      _module.el.find('.ple-module-content')
                .append('<p class="ple-help"><span class="ple-help-minor"></span></p>');

      _module.el.find('.ple-module-content .ple-help-minor')
                .html(_module.options.instructions);

      _module.el.find('.ple-help-minor').css('opacity','0');

    }


    // construct HTML additions
    _module.build();


    _module.el.find('.ple-module-guide').prepend('<div style="display:none;" class="ple-menu-more ple-help-minor pull-right"></div>');
    
    _module.menuEl = _module.el.find('.ple-menu-more');

    // a "more tools" menu, not currently used:
    //_module.menuEl.append('<a class="btn btn-default">...</a>');

    $(_module.el).find('input').keydown(function(e) {

      _editor.validate();

    });

    // make this hide only if another section is clicked, using a 'not' pseudoselector
    $(_module.el).find('input').focusout(function(e) {

      _editor.validate();

    });

    _module.relatedEl = require('./PublicLab.TitleModule.Related.js')(_module);

  }

});

