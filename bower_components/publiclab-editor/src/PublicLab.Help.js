/*
 * UI behaviors and systems to provide helpful tips and guidance.
 */

module.exports = PublicLab.Help = Class.extend({

  init: function(_editor, options) {

    var _help = this;

    _help.options = options || {};

    // enable tooltips
    $(".pl-editor [rel=tooltip], .wk-commands button, .wk-switchboard button").tooltip();


    // this won't work in xs compact state...

    $('.ple-module').mouseleave(function(e) {

      $(this).find('.ple-guide-minor').fadeTo(400,0);

    });

    $('.ple-module').mouseenter(function(e) {

      $(this).find('.ple-guide-minor').fadeTo(400,1);
      
    });



  }

});
