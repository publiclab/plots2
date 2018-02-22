/*
 * Formatters package the post content for a specific
 * application, like PublicLab.org or Drupal.
 */

var Class = require('resig-class');

module.exports = PublicLab.Formatter = Class.extend({


  // eventually we could accept both a format and a URL
  init: function() {

    var _formatter = this;


    // functions that accept standard <data> and output form data for known services
    _formatter.schemas = {
 
      "publiclab": function(data) {
 
        var output = {};
 
        output.title              = data.title || null; 
        output.body               = data.body  || null; 
 
        // we can remove this from server req, since we're authenticated
        output.authenticity_token = data.token || null; 
 
        // Optional:
        output.tags               = data.tags           || null; // comma delimited
        output.has_main_image     = data.has_main_image || null;
        output.main_image         = data.main_image     || null; // id to associate with pre-uploaded image
        output.node_images        = data.node_images    || null; // comma-separated image.ids, I think
        // photo is probably actually a multipart, but we pre-upload anyways, so probably not necessary:
        output.image              = { };  
        output.image.photo        = data.image          || null;
 
        return output;
 
      }//,
 
      // "drupal": {
      //   "title":           null,
      //   "body":            null
      // }
 
    }


    _formatter.convert = function(data, destination) {

      // return formatted version of data
      return _formatter.schemas[destination](data);

    }

  }

});
