/**
  The restful_typeahead.js script provides generic typeahead functionality for the plots2 Rails app.
  The set of functions here are intended to provide a link between the data available through the RESTful
  search API and the UI components.

  Documentation here: https://github.com/bassjobsen/Bootstrap-3-Typeahead
**/

jQuery(document).ready(function() {
  var el = $('input.search-query.typeahead');
  var typeahead = el.typeahead({
    items: 15,
    minLength: 3,
    autoSelect: false,
    source: function (query, process) {
      return $.getJSON('/api/srch/all?srchString=' + query, function (data) {
        return process(data.items);
      },'json');
    },
    highlighter: function (text, item) {
      return '<i class="fa fa-' + item.docType + '"></i> ' + item.docTitle;
    },
    matcher: function() {
      return true;
    },
    displayText: function(item) {
      return item.docTitle;
    },
    updater: function(item) {
      if (item.hasOwnProperty('docUrl') && item.docUrl) {
        window.location = window.location.origin + item.docUrl;
      } else {
        window.location = window.location.origin + '/tag/' + item.docTitle;
      }
      item = item.docTitle;
      return item;
    }
  });
});
