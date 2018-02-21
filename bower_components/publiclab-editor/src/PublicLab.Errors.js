/*
 * Error display; error format is:
 * "title": ["can't be blank"]
 */

module.exports = PublicLab.Errors = Class.extend({

  init: function(_editor, options) {

    var _errors = this;

    _errors.options = options || {};

    if (_errors.options && typeof _errors.options === 'object' && Object.keys(_errors.options).length > 0) {

      $('.ple-errors').append('<div class="alert alert-danger"></div>');

      Object.keys(_errors.options).forEach(function eachField(key, i) {

        _errors.options[key].forEach(function eachError(error, j) {

          $('.ple-errors .alert').append('<p><b>Error:</b> ' + key + ' ' + error + '.</p>');

        });

      });

    }

  }

});
