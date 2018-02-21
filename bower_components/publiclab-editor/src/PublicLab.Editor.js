var Class        = require('resig-class');

PL = PublicLab = {};
module.exports = PL;

PL.Util            = require('./core/Util.js');
PL.Formatter       = require('./adapters/PublicLab.Formatter.js');
PL.Woofmark        = require('./adapters/PublicLab.Woofmark.js');
PL.History         = require('./PublicLab.History.js');
PL.Help            = require('./PublicLab.Help.js');
PL.Errors          = require('./PublicLab.Errors.js');
PL.Module          = require('./modules/PublicLab.Module.js');
PL.TitleModule     = require('./modules/PublicLab.TitleModule.js');
PL.MainImageModule = require('./modules/PublicLab.MainImageModule.js');
PL.RichTextModule  = require('./modules/PublicLab.RichTextModule.js');
PL.TagsModule      = require('./modules/PublicLab.TagsModule.js');


PL.Editor = Class.extend({

  init: function(options) {

    var _editor = this;
    _editor.options = options;
    _editor.options.history = _editor.options.history || true;
    _editor.options.format = "publiclab";

    // Validation:
    // Count how many required modules remain for author to complete:
    _editor.validate = function() {

      var valid_modules    = 0,
          required_modules = 0;

      _editor.modules.forEach(function(module, i) {

        if (module.options.required) {
          required_modules += 1;
          if (module.valid()) valid_modules += 1;
        }

      });

      if (valid_modules == required_modules) {

        $('.ple-publish').removeClass('disabled');

      }

      $('.ple-steps-left').html((required_modules - valid_modules) + ' of ' + required_modules);

      return valid_modules == required_modules;

    }

    $('.ple-editor *').on('focusout keypress blur change keyup', _editor.validate);

    _editor.data = {

      title: null,
      body:  null,
      tags:  null,          // comma-delimited list; this should be added by a PL.Editor.MainImage module
      main_image_url: null

    }

    // Update data based on passed options.data
    for (var attrname in options.data) {
      _editor.data[attrname] = options.data[attrname];
    }


    // Fetch values from modules and feed into corresponding editor.data.foo --
    // Note that modules may attempt to write to the same key, 
    // and would then overwrite one another.
    _editor.collectData = function() {

      _editor.modules.forEach(function(module, i) {

        _editor.data[module.key] = module.value();

      });

    }


    // executes <callback> on completion, or (by default) navigates to returned URL
    _editor.publish = _editor.options.publish || function publish(callback) {

      _editor.collectData();

      var formatted = new PublicLab.Formatter().convert(
                        _editor.data, 
                        _editor.options.format
                      );

      if (_editor.options.destination) {

        $('.ple-publish').html('<i class="fa fa-circle-o-notch fa-spin"></i>');

        $.ajax(
          _editor.options.destination, 
          { 
            data: formatted,
            method: 'POST'
          }
        ).done(function(response) {

          if (callback) callback(response);
          else window.location = response;

        }).fail(function(response) {

          $('.ple-publish').removeClass('btn-success')
                           .addClass('btn-danger');

        });

      } else {

        console.log('Editor requires a destination.');

      }

    }


    _editor.tabIndices = function() {

      // set tabindices:
      var focusables = [];

      _editor.modules.forEach(function(module, i) {
 
        focusables = focusables.concat(module.focusables);
 
      });

      focusables.push($('.ple-publish'));
 
      focusables.forEach(function(focusable, i) {
 
        focusable.attr('tabindex', i + 1);
 
      });

    }


    _editor.eventSetup = function() {


      $('.ple-publish').click(function() {
        console.log('Publishing!', _editor.data);
        _editor.publish(_editor.options.publishCallback);
      });
 
 
      $('.btn-more').click(function() {
 
        // display more tools menu
        $('.ple-menu-more').toggle();
 
      });

    }


    _editor.modules = [];

    // default modules:
    if (_editor.options.titleModule !== false) {
      _editor.titleModule = new PublicLab.TitleModule(_editor);
      _editor.modules.push(_editor.titleModule);
    }

    if (_editor.options.mainImageModule !== false) {
      _editor.mainImageModule = new PublicLab.MainImageModule(_editor);
      _editor.modules.push(_editor.mainImageModule);
    }

    if (_editor.options.richTextModule  !== false) {
      // options are normally passed via the corresponding _editor.options.fooModule object;
      // however, we copy textarea (the most basic) in automatically:
      _editor.options.richTextModule = _editor.options.richTextModule || {};
      _editor.options.richTextModule.textarea = _editor.options.textarea;

      _editor.richTextModule  = new PublicLab.RichTextModule( _editor);
      _editor.modules.push(_editor.richTextModule);

      // history must go after richTextModule, as it monitors that
      if (_editor.options.history) _editor.history = new PublicLab.History(_editor, _editor.options.history);
    }

    if (_editor.options.tagsModule !== false) {
      _editor.tagsModule      = new PublicLab.TagsModule(     _editor);
      _editor.modules.push(_editor.tagsModule);
    }

    _editor.help = new PublicLab.Help(_editor);

    _editor.errors = new PublicLab.Errors(_editor, _editor.options.errors);


    _editor.validate();

    _editor.eventSetup();

    _editor.tabIndices();


  }

});
