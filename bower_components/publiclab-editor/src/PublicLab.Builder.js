/*
 * Methods to construct module HTML in the DOM
 */

module.exports = PublicLab.Builder = Class.extend({

  init: function(_editor, options) {

    var _builder = this;

    _builder.options = options || {};

    options.el = $(options.selector);


    _builder.construct = function(module) {

      // actually fill the element with HTML -- 

    }


  }

});
