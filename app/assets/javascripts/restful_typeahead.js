/**
  The restful_typeahead.js script provides generic typeahead functionality for the plots2 Rails app.
  The set of functions here are intended to provide a link between the data available through the RESTful 
  search API and the UI components.  
  
  Documentation here: https://github.com/bassjobsen/Bootstrap-3-Typeahead
**/

jQuery(document).ready(function() {
  var el = $('input.search-query.typeahead');
  var typeahead = el.typeahead({
    items: 8,
    minLength: 3,
    source: function (query, process) {
      return $.getJSON('/api/typeahead/all?srchString=' + query, function (data) {
        return process(data.items);
      },'json');
    },
    highlighter: function (text, item) {
      return '<i class="fa fa-' + item.tagType + '"></i> ' + item.tagVal;
    },
    displayText: function(item) {
      return item.tagVal;
    },
    updater: function(item) { 
      if (item.hasOwnProperty('tagSource') && item.tagSource) {
        window.location = window.location.origin + item.tagSource;
      } else {
        window.location = window.location.origin + '/tag/' + item.tagVal;
      }
      item = item.tagVal;
      return item;
    }
  });
});
