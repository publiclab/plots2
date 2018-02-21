/*
 * Form module for post tags
 */

module.exports = PublicLab.TagsModule = PublicLab.Module.extend({

  init: function(_editor, options) {

    var _module = this;

    _module.key = 'tags';
    _module.options = options || _editor.options.tagsModule || {};
    _module.options.name         = 'tags';
    _module.options.instructions = 'Tags relate your work to others\' posts. <a href="" target="_blank">Read more &raquo;</a>';
    _module.options.recentTags = [ 'balloon-mapping', 'water-quality' ];
    _module.options.local = _module.options.local || ['balloon-mapping','kite-mapping','air-quality','spectrometer','water-quality'];
    _module.options.prefetch = _module.options.prefetch || null;

    _module._super(_editor, _module.options);

    _module.options.initialValue = _editor.options[_module.key] || _module.el.find('input').val();
    _module.options.required     = false;
    _module.options.instructions = 'Tags connect your work with similar content, and make your work more visible. <a href="" target="_blank">Read more &raquo;</a>';

    _module.value = function(text) {

      if (typeof text == 'string') {

        _module.el.find('input').val(text);

      }

      var tags = _module.el.find('input').val();

      if (_editor.data.hasOwnProperty(_module.key)
       && _editor.data[_module.key] !== null
       && _editor.data[_module.key] !== '') {

        tags = _editor.data[_module.key] + ',' + tags;

      }

      return tags;

    }

    _module.value(_module.options.initialValue);


    // server-side validation for now, and not required, so no reqs
    _module.valid = function() {

      return true;

    }


    // Overrides default build method
    _module.build = function() {

      // custom location -- just under the input
      _module.el.find('.ple-module-content')
                .append('<p class="ple-help"><span class="ple-help-minor"></span></p>');

      _module.el.find('.ple-module-content .ple-help-minor')
                .html(_module.options.instructions);

      // https://github.com/twitter/typeahead.js/blob/master/doc/bloodhound.md
      _module.engine = new Bloodhound({
        local: _module.options.local,
        remote: _module.options.remote,
        datumTokenizer: Bloodhound.tokenizers.whitespace,
//        datumTokenizer: function(d) {
//          return Bloodhound.tokenizers.whitespace(d.value);
//        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        prefetch: _module.options.prefetch
      });

      _module.engine.initialize();

      _module.el.find('input').tokenfield({
        typeahead: [null, { source: _module.engine.ttAdapter() }],
        delimiter: ', '
      });


      // add to tabindex only after we've created the tokenfield instance
      _module.focusables.push(_module.el.find('.tokenfield .tt-input'));


      // insert recent and common ones here --
      // (this is application-specific)

      _module.el.find('.ple-module-content')
                .append('<p class="ple-help-minor">Recent tags: <span class="ple-recent-tags"></span></p>');

      var tags = [];

      _module.options.recentTags.forEach(function(tag) {

        tags.push('<a>' + tag + '</a>');

      });

      _module.el.find('.ple-recent-tags')
                .append(tags.join(', '))

      _module.el.find('.ple-help-minor').css('opacity','0');

    }


    // construct HTML additions
    _module.build();


  }

});
