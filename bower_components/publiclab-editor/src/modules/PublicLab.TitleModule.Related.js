/* Displays related posts to associate this one with. 
 * Pass this a fetchRelated() method which runs show() with returned JSON data.
 * Example:

```js
function fetchRelated(show) {

  $.getJSON('/some/url', function(response) {

    show(response);

  });

}
```

Results should be in following JSON format:

[
  { id: 1, title: 'A related post',       url: '/', author: 'eustatic'},
  { id: 2, title: 'Another related post', url: '/', author: 'stevie'},
  { id: 3, title: 'A third related post', url: '/', author: 'bsugar'}
]

 */
module.exports = function relatedNodes(module) {

  var relatedEl;

  build();
  bindEvents()

  // make an area for "related posts" to connect to
  function build() { 

    module.el.find('.ple-module-content').append('<div style="display:none;" class="ple-title-related"></div>');
    relatedEl = module.el.find('.ple-title-related');
    relatedEl.append('<p class="ple-help">Does your work relate to one of these? Click to alert those contributors.</p><hr style="margin: 4px 0;" />');

  }

  // expects array of results in format:
  // { id: 3, title: 'A third related post', url: '/', author: 'bsugar'}
  function show(relatedResults) { 

    relatedEl.find('.result').remove();

    relatedResults.slice(0, 8).forEach(function(result) {

      relatedEl.append('<div class="result result-' + result.id + '" style="margin: 3px;"><a class="btn btn-xs btn-default add-tag"><i class="fa fa-plus-circle"></i> Add</a> <a class="title"></a> by <a class="author"></a></div>');
      relatedEl.find('.result-' + result.id + ' .title').html(result.title);
      relatedEl.find('.result-' + result.id + ' .title').attr('href', result.url);
      relatedEl.find('.result-' + result.id + ' .author').html('@' + result.author);
      relatedEl.find('.result-' + result.id + ' .author').attr('href', '/profile/' + result.author);

      $('.result-' + result.id + ' .add-tag').click(function() {
        editor.tagsModule.el.find('input').tokenfield('createToken', 'response:' + result.id);
        // pending https://github.com/publiclab/plots2/issues/646
        // editor.tagsModule.el.find('input').tokenfield('createToken', 'notify:' + result.author);
        $('.result-' + result.id).remove();
      });

    });

  }

  var fetchRelated = module.options.fetchRelated || function fetchRelated(show) {

    // example
    show([
      { id: 1, title: 'A related post',       url: '/', author: 'eustatic'},
      { id: 2, title: 'Another related post', url: '/', author: 'stevie'},
      { id: 3, title: 'A third related post', url: '/', author: 'bsugar'}
    ]);

  }

  function bindEvents() {

    $(module.el).find('input').keydown(function(e) {
 
      if (module.options.suggestRelated) {
        relatedEl.fadeIn();
        fetchRelated(show);
      }
 
    });
 
    $(module.el).find('input').focusout(function(e) {
 
      if (module.options.suggestRelated) {
        relatedEl.fadeOut();
      }
 
    });

  }

  return relatedEl;

}
