/*
 * Form modules like title, tags, body, main image
 */

module.exports = PublicLab.Module = Class.extend({

  init: function(_editor, options) {

    var _module = this;

    _module.options = options || {};
    _module.options.required = false; // default
    _module.options.guides = _module.options.guides || [];
    _module.focusables = []; // tab-focusable elements

    _module.el = $('.ple-module-' + _module.options.name);


    // Construct and insert HTML, including 
    // instructions, help and tips
    _module.build = function() {    

      // standard instructions location is at start of ple-module-guide 
      _module.el.find('.ple-module-guide')
                .append('<p class="ple-instructions">' + _module.options.instructions + '</p>')
                .append('<div class="ple-guide-minor hidden-xs hidden-sm" style = "opacity:0;"></div>');

      _module.options.guides.forEach(function(guide) {

        _module.el.find('.ple-guide-minor')
                  .append('<br style="position:absolute;top:' + guide.position + 'px;" class="hidden-xs hidden-sm" />')
                  .append('<p><i class="fa fa-' + guide.icon + '"></i>' + guide.text + '</p>');

      });
 
    }


    // All modules must have a module.valid() method
    // which returns true by default (making them optional).
    // Eventually, we might distinguish between empty and invalid.
    _module.valid = function() {

      return true;

    }


    // could wrap these in an events() method?
    _module.el.find('.ple-help-minor').hide(); 


    $(_module.el).mouseenter(function() { 

      _module.el.find('.ple-help-minor').fadeTo(400,1);

    });

    $(_module.el).mouseleave(function() { 

      _module.el.find('.ple-help-minor').fadeTo(400,0);
      
    });


  }

});
